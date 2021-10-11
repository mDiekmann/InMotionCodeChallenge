//
//  ImageDataModelTests.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/7/21.
//

import XCTest
@testable import InMotionCodeChallenge

class ImageDataModelTests: ImageTestBase {

    enum TestFile: String {
        case valid = "test_image_standard"
        case minimum = "test_image_minimum_data"
        case missingId = "test_image_missing_id"
        case missingImageUrl = "test_image_missing_image_url"
    }
    
    // MARK: Test Constructor
    func testImageDataModelInit() throws {
        let testImage = imageFromInit()
        
        try testValidImageDataModel(testImage)
    }
    
    // MARK: Test Decoding
    // MARK: Valid use cases
    func testValidUserDecoder() throws {
        let data = try loadJSONFile(TestFile.valid)
        let testImage = try JSONDecoder().decode(ImageDataModel.self, from: data)
        
        try testValidImageDataModel(testImage)
    }
    
    func testMinimumResponse() throws {
        let data = try loadJSONFile(TestFile.minimum)
        let testImage = try JSONDecoder().decode(ImageDataModel.self, from: data)
        
        XCTAssertEqual(testImage.id, testId, "ID values not equal")
        XCTAssertNil(testImage.author, "Author should be be nil")
        XCTAssertNil(testImage.width, "Width should be be nil")
        XCTAssertNil(testImage.height, "height should be be nil")
        XCTAssertEqual(testImage.imageURL, testImageURL, "Image URL values not equal")
    }
    
    func testForThrownError(fileId: TestFile, errorType: ImageDataModelError) throws {
        let data = try loadJSONFile(fileId)
        XCTAssertThrowsError(try JSONDecoder().decode(ImageDataModel.self, from: data)) { error in
            XCTAssertEqual(error as! ImageDataModelError, errorType)
        }
    }
    
    //MARK: Missing necessary data
    func testMissingId() throws {
        try testForThrownError(fileId: .missingId, errorType:.missingId)
    }
    
    func testMissingImageUrl() throws {
        try testForThrownError(fileId: .missingImageUrl, errorType:.missingAssociatedImage)
    }

    //MARK: Test Encoding
    // not currently uploading anything to a server, so nothing to test

}
