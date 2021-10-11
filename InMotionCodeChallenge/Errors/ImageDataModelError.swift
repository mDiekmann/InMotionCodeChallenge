//
//  ImageDataModelError.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation

enum ImageDataModelError: Error, Equatable {
    // decoding errors
    case missingId
    case missingAssociatedImage
    
    // encoding errors
}

extension ImageDataModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .missingId:
                return "Image date model must contain an ID value. No value found when decoding."
            case .missingAssociatedImage:
                return "Image date model must contain an image URL. No URL found when decoding."
        }
    }
}
