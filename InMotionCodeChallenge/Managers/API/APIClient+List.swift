//
//  APIClient+List.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation
import Combine

extension APIClient {
    struct GetImagesFromList: Request {
        var path: String = ""
        var httpMethod: HTTPMethod = .get
        var contentType: ContentType = .xForm
        var queryParams: [URLQueryItem]? = nil
        typealias ReturnType = [ImageDataModel]
    }
    
    func getImageListRequest(currentPage: Int, fetchLimit: Int) -> GetImagesFromList {
        let path = getPathWithAPIVersion("list")
        let queryParams = [ URLQueryItem(name: "page", value: String(currentPage)),
                            URLQueryItem(name: "limit", value: String(fetchLimit))]
        
        return GetImagesFromList(path: path, queryParams: queryParams)
    }
    
    func getImageList(currentPage: Int, fetchLimit: Int) -> AnyPublisher<GetImagesFromList.ReturnType, NetworkRequestError> {
        let imageListRequest = getImageListRequest(currentPage: currentPage, fetchLimit: fetchLimit)
        
        return dispatch(imageListRequest)
    }
}
