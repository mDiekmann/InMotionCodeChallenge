//
//  ImageDataModel.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import Foundation

struct ImageDataModel: Codable, ObjectConvertible {
    var identifier: String?
    
    // values from API endpoint
    var id: Int32
    var author: String
    var width, height: Int16
    var imageURL: String
}
