//
//  ImageDataModelError.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation

enum ImageDataModelError: Error, Equatable {
    // decoding errors
    case idConversion
    case missingId
    case invalidIdValue(Int32)
    case missingAssociatedImage
    
    // encoding errors
}

extension ImageDataModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .idConversion:
                return "Error when decoding ID value"
            case .missingId:
                return "Image date model must contain an ID value. No value found when decoding."
            case .invalidIdValue(let value):
                return "Invalid ID of \(value) found when decoding. ID values must be >= 0"
            case .missingAssociatedImage:
                return "Image date model must contain an image URL. No URL found when decoding."
        }
    }
}
