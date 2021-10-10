//
//  APITestBase.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/8/21.
//

import XCTest
import Combine
@testable import InMotionCodeChallenge

class APITestBase: MDTestFileBase {

    var apiClient: APIClient!
    var cancellables = [AnyCancellable]()
    
    enum TestFile: String {
        case equalToRequest_200 = "test_api_get_list_equal_to_requested_200"
        case lessThanRequested_200 = "test_api_get_list_less_than_requested_200"
    }
    
    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        apiClient = APIClient(urlSession: urlSession)
    }
    
    func createMockRequestHandler<T: Request>(request:T, statusCode: Int, responseData: Data) throws -> ((URLRequest) throws -> (HTTPURLResponse, Data)) {
        let imageListRequest = request.asURLRequest(baseURL: apiClient.baseURL)
        
        guard let url = imageListRequest?.url else {
            throw TestError.invalidURLForRequest(String(describing: request))
        }
        
        return { retRequest in
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: imageListRequest?.allHTTPHeaderFields)!
            return (response, responseData)
        }
    }

    private func testStatusCodeError(statusCode: Int, error: NetworkRequestError) throws {
        let currentPage = 0
        let fetchLimit = 20
        
        let finishedExpectation = expectation(description: "Invalid finished")
        finishedExpectation.isInverted = true
        let successExpectation = expectation(description: "Invalid receiveValue")
        successExpectation.isInverted  = true
        let failExpectaion = expectation(description: "Failure")
        
        let data = try loadJSONFile(TestFile.equalToRequest_200)
        let imageListRequest = apiClient.getImageListRequest(currentPage: currentPage, fetchLimit: fetchLimit)
        let requestHandler = try self.createMockRequestHandler(request: imageListRequest, statusCode: statusCode, responseData: data)
        
        MockURLProtocol.requestHandler = requestHandler
        apiClient.getImageList(currentPage: currentPage, fetchLimit: fetchLimit).sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let respError):
                        XCTAssertEqual(error, respError)
                        failExpectaion.fulfill()
                    case .finished :
                        finishedExpectation.fulfill()
                }
            },
            receiveValue: { response in
                successExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [finishedExpectation, successExpectation, failExpectaion], timeout: 1.0)
    }
    
    // general testing of status code errors in response
    // should only need to be done once for entire api since all code runs through the same area
    func testBadRequestError() throws {
        try testStatusCodeError(statusCode: 400, error: .badRequest)
    }
    
    func testUnauthorizedError() throws {
        try testStatusCodeError(statusCode: 401, error: .unauthorized)
    }
    
    func testForbiddenError() throws {
        try testStatusCodeError(statusCode: 403, error: .forbidden)
    }
    
    func testNotFoundError() throws {
        try testStatusCodeError(statusCode: 404, error: .notFound)
    }
    
    func test400Error() throws {
        try testStatusCodeError(statusCode: 405, error: .error4xx(405))
    }
    
    func testServerError() throws {
        try testStatusCodeError(statusCode: 500, error: .serverError)
    }

    func test500Error() throws {
        try testStatusCodeError(statusCode: 501, error: .error5xx(501))
    }
}
