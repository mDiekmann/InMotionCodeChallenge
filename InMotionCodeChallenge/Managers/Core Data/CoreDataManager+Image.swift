//
//  CoreDataManager+Image.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import Foundation

extension CoreDataManager {
    func addImages(_ images: [ImageDataModel]) {
        for image in images {
            addImage(image)
        }
    }
    
    func addImage(_ image: ImageDataModel) {
        let context = backgroundContext
        
        do {
            try Image.insert(image, with: context)
        } catch {
            //TODO: Use a logger
            print("Error(\(error.localizedDescription)) when saving image \(image.id)")
        }
    }
    
    func updateImage(_ image: ImageDataModel) {
        let context = backgroundContext
        
        do {
            try Image.update(image, with: context)
        } catch {
            //TODO: Use a logger
            print("Error(\(error.localizedDescription)) when saving image \(image.id)")
        }
    }
}
