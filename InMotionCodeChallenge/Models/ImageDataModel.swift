//
//  ImageDataModel.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import Foundation

class ImageDataModel: Codable, Equatable, ObjectConvertible {
    static func == (lhs: ImageDataModel, rhs: ImageDataModel) -> Bool {
        (lhs.id == rhs.id) && (lhs.imageURL == rhs.imageURL)
    }
    
    var identifier: String?
    
    // values from API endpoint
    // must have values to display an Image
    var id: String
    var imageURL: String
    
    // optional values
    var author: String?
    var width, height: Int16?
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case imageURL = "download_url"
    }
    
    init(id: String, author: String?, width: Int16?, height: Int16?, imageURL: String) {
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.imageURL = imageURL
    }
    
    // MARK: - Decodable
    required init (from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        // check for existence instead of just letting standard decode throw error to get more specific error
        if let idStr = try container.decodeIfPresent(String.self, forKey: .id) {
            self.id = idStr
        } else {
            throw ImageDataModelError.missingId
        }
        
        // check for existence instead of just letting standard decode throw error to get more specific error
        if let imageURLStr = try container.decodeIfPresent(String.self, forKey: .imageURL) {
            // images provided from api are HUUGE, luckily they provide a way to specify size
            let urlArr = imageURLStr.components(separatedBy: "/")
            let scaledWidth = (Int(urlArr[5]) ?? 1)/10
            let scaledHeight = (Int(urlArr[6]) ?? 1) / 10
            var urlStr = imageURLStr.replacingOccurrences(of: urlArr[5], with: String(scaledWidth))
            urlStr = urlStr.replacingOccurrences(of: urlArr[6], with: String(scaledHeight))
            self.imageURL = urlStr
        } else {
            throw ImageDataModelError.missingAssociatedImage
        }
        
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.width = try container.decodeIfPresent(Int16.self, forKey: .width)
        self.height = try container.decodeIfPresent(Int16.self, forKey: .height)
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(id), forKey: .id)
        try container.encode(author, forKey: .author)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(imageURL, forKey: .imageURL)
    }
}
