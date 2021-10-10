//
//  APIListTest.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/8/21.
//

import XCTest
@testable import InMotionCodeChallenge

class APIListTest: APITestBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValid200Response() throws {
        let currentPage = 0
        let fetchLimit = 20
        
        let finishedExpectation = expectation(description: "finished")
        let successExpectation = expectation(description: "Return count = fetch count")
        let failExpectaion = expectation(description: "Failure")
        failExpectaion.isInverted = true
        
        let data = try loadJSONFile(TestFile.equalToRequest_200)
        let imageListRequest = apiClient.getImageListRequest(currentPage: currentPage, fetchLimit: fetchLimit)
        let requestHandler = try createMockRequestHandler(request: imageListRequest, statusCode: 200, responseData: data)
        
        MockURLProtocol.requestHandler = requestHandler
        apiClient.getImageList(currentPage: currentPage, fetchLimit: fetchLimit).sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        XCTFail("Unexpected error received: \(error)")
                        failExpectaion.fulfill()
                    case .finished :
                        finishedExpectation.fulfill()
                }
            },
            receiveValue: { response in
                XCTAssertEqual(response.count, fetchLimit, "Expected count not equal to returned count")
                successExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [finishedExpectation, successExpectation, failExpectaion], timeout: 1.0)
    }
    
    // test receiving less than the expected amount of items returned
    func testLessThanExpected200Response() throws {
        let currentPage = 0
        let fetchLimit = 20
        
        let finishedExpectation = expectation(description: "finished")
        let successExpectation = expectation(description: "Return count != fetch count")
        let failExpectaion = expectation(description: "Failure")
        failExpectaion.isInverted = true
        
        let data = try loadJSONFile(TestFile.lessThanRequested_200)
        let imageListRequest = apiClient.getImageListRequest(currentPage: currentPage, fetchLimit: fetchLimit)
        let requestHandler = try createMockRequestHandler(request: imageListRequest, statusCode: 200, responseData: data)
        
        MockURLProtocol.requestHandler = requestHandler
        apiClient.getImageList(currentPage: currentPage, fetchLimit: fetchLimit).sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        XCTFail("Unexpected error received: \(error)")
                        failExpectaion.fulfill()
                    case .finished :
                        finishedExpectation.fulfill()
                }
            },
            receiveValue: { response in
                XCTAssertNotEqual(response.count, fetchLimit, "Expected count not equal to returned count")
                successExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [finishedExpectation, successExpectation, failExpectaion], timeout: 1.0)
    }
    
    func testDecodingError() throws {
        let currentPage = 0
        let fetchLimit = 20
        
        let finishedExpectation = expectation(description: "Invalid finished")
        finishedExpectation.isInverted = true
        let successExpectation = expectation(description: "Invalid receiveValue")
        successExpectation.isInverted  = true
        let failExpectaion = expectation(description: "Failure")
        
        // empty data to force a bad decoding
        let data = Data()
        let imageListRequest = apiClient.getImageListRequest(currentPage: currentPage, fetchLimit: fetchLimit)
        let requestHandler = try createMockRequestHandler(request: imageListRequest, statusCode: 200, responseData: data)
        
        MockURLProtocol.requestHandler = requestHandler
        apiClient.getImageList(currentPage: currentPage, fetchLimit: fetchLimit).sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let respError):
                        XCTAssertEqual(.decodingError, respError)
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
    
}
