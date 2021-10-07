//
//  Image.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import Foundation
import CoreData


public class Image: NSManagedObject, ManagedObjectConvertible {
    typealias T = ImageDataModel
    
    func from(object: ImageDataModel) {
        self.id = object.id
        self.author = object.author
        self.height = object.height
        self.width = object.width
        self.imageUrl = object.imageURL
    }
    
    func toObject() -> ImageDataModel {
        var returnImage = ImageDataModel(id: self.id,
                                         author: self.author ?? "",
                                         width: self.width,
                                         height: self.height,
                                         imageURL: self.imageUrl ?? "")
        
        returnImage.identifier = self.identifier
        return returnImage
    }
}
