//
//  ImageCache.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit
import Combine

let imageCache = ImageCache()

class ImageCache: NSObject {
    private let cachedImagesInMemory = NSCache<NSURL, UIImage>()
    private let cachedImagesOnDisk = DiskCache<UIImage>()
    
    private lazy var backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        return queue
    }()
    
    private func imageForUrlFromMemoryCache(_ url: URL) -> UIImage? {
        return cachedImagesInMemory.object(forKey: url as NSURL)
    }
    
    private func imageForUrlFromDiskCache(_ url: URL, forKey key: String) -> UIImage? {
        return cachedImagesOnDisk.object(forKey: key)
    }
    
    private func getRemoteImageFromURL(_ url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
                .map {
                    (data, response) -> UIImage? in return UIImage(data: data)
                }
                .catch {
                    error in return Just(nil)
                }
                .handleEvents(receiveOutput: {[weak self] image in
                    guard let image = image,
                          let self = self else { return }
                    self.cachedImagesOnDisk.setObject(image, forKey: String(url.hashValue))
                    self.cachedImagesInMemory.setObject(image, forKey: url as NSURL)
                })
                .subscribe(on: backgroundQueue)
                .retry(3)
                .eraseToAnyPublisher()
    }
    
    // loads image to cache if not already available
    // helpful for preloading images in feed for better user eperience
    func loadImageIfNotInCache(imageUrl url: URL, forKey key: String) {
        if let  _ = imageForUrlFromMemoryCache(url) {
            // image is in memory cache so we are all set
            return
        }
        
        if let cachedImage = imageForUrlFromDiskCache(url, forKey: key) {
            // image exists in disk cache, load to memory for quick access and return
            self.cachedImagesInMemory.setObject(cachedImage, forKey: url as NSURL)
        }
        
        // image is not in disk or memory cache, load to cache from URL
        _ = getRemoteImageFromURL(url)
    }
    
    // will first check for image in memory cache, and return that if available
    // otherwise will attempt to retrieve image from URL and return that
    func loadImageFromURL(_ url: URL, forKey key: String) -> AnyPublisher<UIImage?, Never> {
        // try and retrieve from in memory cache
        if let cachedImage = imageForUrlFromMemoryCache(url) {
            // if image exists in cache return that
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // if not there check to see if it's already downloaded and in the cache
        if let cachedImage = imageForUrlFromDiskCache(url, forKey: key) {
            // if image exists in disk cache return that and load to memory cache
            self.cachedImagesInMemory.setObject(cachedImage, forKey: url as NSURL)
            return Just(cachedImage).eraseToAnyPublisher()
        }

        // otherwise try and retrieve from URL
        return getRemoteImageFromURL(url)
    }
}
