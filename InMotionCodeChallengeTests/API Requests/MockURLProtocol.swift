//
//  MockURLProtocol.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/8/21.
//

import Foundation

class MockURLProtocol: URLProtocol {
    // handler to test the request and return mock response
    //contains the HTTPURLResponse(URL, response code, header fields) and data to be returned
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    // To check if this protocol can handle the given request.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // Here you return the canonical version of the request but most of the time you pass the orignal one.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    // This is where you create the mock response as per your test case and send it to the URLProtocolClient.
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Mock URLRequest is not set. Set mockRequest with a mock request to allow for testing")
        }
        // respon on background thread, similiar to an actual response
        DispatchQueue.global(qos: .default).async {
            do {
                let (response, data)  = try handler(self.request)
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            } catch  {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }
        //self.client?.urlProtocol(self, didLoad: data)
        // mark that we've finished
        //self.client?.urlProtocolDidFinishLoading(self)
    }

    // This is called if the request gets canceled or completed.
    override func stopLoading() { }
}

