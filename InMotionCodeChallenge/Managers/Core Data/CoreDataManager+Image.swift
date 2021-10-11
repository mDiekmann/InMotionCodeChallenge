//
//  CoreDataManager+Image.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import Foundation
import CoreData

extension CoreDataManager {
    func addImages(_ images: [ImageDataModel]) {
        for image in images {
            addImage(image)
        }
    }
    
    func addImage(_ image: ImageDataModel) {
        let context = managedObjectContext
        
        do {
            try Image.insert(image, with: context)
        } catch {
            //TODO: Use a logger
            print("Error(\(error.localizedDescription)) when saving image \(image.id)")
        }
    }
    
    func fetchAllImages(sortById: Bool = false) -> [ImageDataModel]? {
        let context = managedObjectContext
        
        var sortDescriptor = [NSSortDescriptor]()
        if sortById {
            sortDescriptor = [NSSortDescriptor(key: "id", ascending: true)]
        }
        
        let retImages = Image.fetchAll(from: context, withSortDescriptors: sortDescriptor)
        
        return retImages
    }
    
    func getAllImagesCount() -> Int {
        let context = managedObjectContext
        var retCount = 0
        do {
            let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
            retCount = try context.count(for: fetchRequest)
        } catch {
            //TODO: Use a logger
            print("Error(\(error.localizedDescription)) when getting total image count")
        }
        
        return retCount
    }
    
    func updateImage(_ image: ImageDataModel) {
        let context = managedObjectContext
        
        // if identifier is set we have a reference to the DB object address and can use the standard update
        if image.identifier != nil {
            do {
                try Image.update(image, with: context)
            } catch {
                //TODO: Use a logger
                print("Error(\(error.localizedDescription)) when updating image \(image.id)")
            }
        } else {
            // if not we need to retrieve the object from the id and update that
            do {
                let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id = %@", image.id)
                
                let images = try context.fetch(fetchRequest)
                
                if let imageRecord = images.first {
                    imageRecord.from(object: image)
                    try context.save()
                }
            } catch {
                //TODO: Use a logger
                print("Error(\(error.localizedDescription)) when updating image \(image.id)")
            }
        }
    }
    
    func removeImage(_ image: ImageDataModel) {
        let context = managedObjectContext
        // if identifier is set we have a reference to the DB object address and can use the standard delete
        if image.identifier != nil {
            do {
                try Image.remove(image, with: context)
            } catch {
                //TODO: Use a logger
                print("Error(\(error.localizedDescription)) when deleting image \(image.id)")
            }
        } else {
            // if not we need to retrieve the object from the id and delete that
            do {
                let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id = %@", image.id)
                
                let images = try context.fetch(fetchRequest)
                
                for image in images {
                    context.delete(image)
                }

                try context.save()
            } catch {
                //TODO: Use a logger
                print("Error(\(error.localizedDescription)) when deleting image \(image.id)")
            }
        }
    }
    
    func removeAllImages() {
        let context = managedObjectContext
        
        do {
            try Image.removeAll(from: context)
        } catch {
            //TODO: Use a logger
            print("Error(\(error.localizedDescription)) when deleting all images")
        }
    }
}
