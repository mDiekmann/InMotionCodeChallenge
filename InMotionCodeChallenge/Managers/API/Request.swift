//
//  Request.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation

protocol Request {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var contentType: ContentType { get }
    var httpBody: Data? { get }
    var headers: [String: String]? { get }
    var queryParams: [URLQueryItem]? { get }
    
    associatedtype ReturnType: Codable
}

extension Request {
    //defualt values
    var httpMethod: HTTPMethod { return .get }
    var contentType: ContentType { return .json }
    var httpBody: Data? { return nil }
    var headers: [String: String]? { return nil }
    var queryParams: [URLQueryItem]? { return nil }
    
    func asURLRequest(baseURL: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURL
        components.path = path.first == "/" ? path : "/" + path
        components.queryItems = queryParams?.isEmpty ?? true ? nil : queryParams
        
        guard let url = components.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        // set method
        urlRequest.httpMethod = httpMethod.rawValue
        
        // special handling for x-www-form-urlencoded types
        // create http body from query data
        if contentType == .xForm && httpMethod != .get {
            urlRequest.httpBody = components.query?.data(using: .utf8)
        } else {
            urlRequest.httpBody = httpBody
        }
        
        var requestHeaders = [String: String]()
        var contentTypeVal = contentType.rawValue
        if contentType == .multipart {
            // need to add boundary for multipart types
            let boundary = "Boundary-\(UUID().uuidString)"
            contentTypeVal += boundary
        }
        requestHeaders["Content-Type"] = contentTypeVal
        // if header were passed in, merge them with the generated headers
        if let headers = headers {
            requestHeaders.merge(headers) {(_,new) in new}
        }

        // set header
        urlRequest.allHTTPHeaderFields = requestHeaders
        
        return urlRequest
    }
}
