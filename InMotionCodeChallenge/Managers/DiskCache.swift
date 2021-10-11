//
//  DiskCache.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import Foundation

import Foundation

class DiskCache<ObjectType> : NSObject where ObjectType : AnyObject{
    
    private let fileManager = FileManager()
    private let queue = DispatchQueue(label: "co.mtd.InMotionCodeChallenge.DiskCache", attributes: DispatchQueue.Attributes.concurrent)
    
    private var currCacheSize : UInt64 = 0
    private var maxCacheSize : UInt64 = 0 {
        didSet {
            self.queue.async(execute: {
                self.manageCacheSize()
            })
        }
    }
    
    // initialize with cache capacity in bytes
    // default to 512 MB = 512000000 bytes
    public init(capacity: UInt64 = 512000000) {
        super.init()
        
        self.maxCacheSize = capacity
        self.queue.async(execute: {
            self.calculateCurrentCacheSize()
            self.manageCacheSize()
        })
    }
    
    private func getCacheDirectoryURL() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
      }
    
    // MARK: Cache Size Management
    private func calculateCurrentCacheSize() {
        // get the current space being consumed by the image cache
        do {
            currCacheSize = 0
            let directoryContents = try fileManager.contentsOfDirectory( at: getCacheDirectoryURL(), includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: file.path)
                    if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                        currCacheSize += fileSize
                    }
                } catch {
                    print("Failed to set current cache size : \(error.localizedDescription)")
                }
            }
            
        } catch {
            print("Failed to set current cache size : \(error.localizedDescription)")
        }
    }
    
    // compares current amoutn of disk space currently being used to requested space
    // and cleans up items from oldest to newest as needed
    private func manageCacheSize() {
        // if size is within limits return immediately
        if self.currCacheSize <= self.maxCacheSize { return }
                
        
        let fileManager = FileManager.default
        let key = URLResourceKey.contentAccessDateKey
        do {
            var files = try fileManager.contentsOfDirectory(at: getCacheDirectoryURL(), includingPropertiesForKeys: [key], options: [.skipsHiddenFiles])
            // sort based on the last time they were used
            try files.sort {
                let values1 = try $0.resourceValues(forKeys: [key])
                let values2 = try $1.resourceValues(forKeys: [key])

                if let date1 = values1.allValues.first?.value as? Date, let date2 = values2.allValues.first?.value as? Date {

                    return date1.compare(date2) == (.orderedAscending)
                }
                return true
            }
            
            // runthrough the items and delete until requested cache size is reached
            for file in files {
                if self.currCacheSize <= self.maxCacheSize {
                    break
                }
                
                self.deleteFile(file)
            }
        } catch {
            print("Failed to manage current cache size : \(error.localizedDescription)")
        }
    }
    
    private func deleteFile(_ url: URL) {
        self.deleteFile(url.path)
    }
    
    // delete the file and update the cache size
    private func deleteFile(_ path: String) {
        do {
            let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: path)
            try fileManager.removeItem(atPath: path)
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                self.substractFromCacheSize(size: fileSize)
            }

        } catch {
            print("Failed to remove file \(path) : \(error.localizedDescription)")
        }
    }

    private func substractFromCacheSize(size : UInt64) {
        if (self.currCacheSize >= size) {
            self.currCacheSize -= size
        } else {
            // this shouldn't happen, but just in case go to 0 instead of negative value
            self.currCacheSize = 0
        }
    }
    
    private func addDataToCache(_ data: Data, forKey key: String) {
        let path = self.pathForKey(key)
        // in case of a file that was previously added being added again,
        // get the size of the current file and so we can update the cache size properly
        let previousAttributes : [FileAttributeKey: Any]? = try? fileManager.attributesOfItem(atPath: path)
        
        do {
            try data.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomicWrite)
        } catch {
            print("Failed to write key \(key) : \(error.localizedDescription)")
        }
        
        // file previously existed and was overwritten, remove the previous files size to keep cache in sync
        if let attributes = previousAttributes {
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                self.substractFromCacheSize(size: fileSize)
            }
        }
        
        // add current file size to cache
        self.currCacheSize += UInt64(data.count)
        // manage cache size to make sure we are not over size limit
        self.manageCacheSize()
    }
    
    //MARK: Cache functions
    func object(forKey key: String) -> ObjectType? {
        let path = pathForKey(key)
        var retObj: ObjectType? = nil
        self.queue.sync (execute: {
            if let objData = fileManager.contents(atPath: path) {
                do {
                    retObj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(objData) as? ObjectType
                } catch {
                    print("Failed to add object to cache : \(key)")
                }
            }
        })
        
        return retObj
    }
    
    func setObject(_ obj: ObjectType, forKey key: String) {
        self.queue.async(execute: {
            do {
                let objData = try NSKeyedArchiver.archivedData(withRootObject: obj, requiringSecureCoding: false)
                self.addDataToCache(objData, forKey: key)
            } catch {
                print("Failed to add object to cache : \(key)")
            }
        })
    }
    
    func removeObject(forKey key: String) {
        self.queue.async(execute: {
            let path = self.pathForKey(key)
            self.deleteFile(path)
        })
    }
    
    private func pathForKey(_ key: String) -> String {
        return getCacheDirectoryURL().appendingPathComponent(key).path
    }
}
