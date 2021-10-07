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
        case invalidId = "test_image_invalid_id"
        case missingId = "test_image_missing_id"
        case missingImageUrl = "test_image_missing_image_url"
        
        case idOutOfRangeHigh = "test_image_id_out_of_range_high"
        case idOutOfRangeLow = "test_image_id_out_of_range_low"
        case idWhitespace = "test_image_id_whitespace"
        case idInvalidChars = "test_image_id_invalid_chars"
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
    
    //MARK: ID < 0
    func testInvalidId() throws {
        try testForThrownError(fileId: .invalidId, errorType:.invalidIdValue(testInvalidId))
    }
    
    //MARK: Missing necessary data
    func testMissingId() throws {
        try testForThrownError(fileId: .missingId, errorType:.missingId)
    }
    
    func testMissingImageUrl() throws {
        try testForThrownError(fileId: .missingImageUrl, errorType:.missingAssociatedImage)
    }

    //MARK: Id related issues
    func testIdOutOfRangeHigh() throws {
        // bounds checking
        try testForThrownError(fileId: .idOutOfRangeHigh, errorType:.idConversion)
    }
    
    func testIdOutOfRangeLow() throws {
        // bounds checking
        try testForThrownError(fileId: .idOutOfRangeLow, errorType:.idConversion)
    }
    
    func testIdContainsWhitespace() throws {
        // 
        try testForThrownError(fileId: .idWhitespace, errorType:.idConversion)
    }
    
    func testIdInvalidChars() throws {
        try testForThrownError(fileId: .idInvalidChars, errorType:.idConversion)
    }
    //MARK: Test Encoding
    // not currently uploading anything to a server, so nothing to test

}
