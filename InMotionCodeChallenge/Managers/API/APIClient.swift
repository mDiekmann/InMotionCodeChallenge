//
//  APIClient.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation
import Combine

class APIClient {
    #if DEBUG
        let baseURL = "picsum.photos"
    #else
        let baseURL = "picsum.photos"
    #endif
    
    // can be overridden in subclasses if differing API versions for different endpoints
    var apiVersion = "v2"
    
    let requestManager: RequestManager!
    
    init(urlSession: URLSession = .shared) {
        requestManager = RequestManager(baseURL: baseURL, urlSession: urlSession)
    }
    
    init() {
        requestManager = RequestManager(baseURL: baseURL)
    }
    
    func getPathWithAPIVersion(_ path: String) -> String {
        let retPath = path.first == "/" ? path : "/" + path
        return "/\(apiVersion)/\(retPath)"
    }
    
    func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
            
        }
        typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        let requestPublisher: RequestPublisher = requestManager.dispatch(request: urlRequest)
        return requestPublisher.eraseToAnyPublisher()
    }
}
