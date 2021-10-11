//
//  ImageTestBase.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/7/21.
//

import XCTest
@testable import InMotionCodeChallenge

class ImageTestBase: MDTestFileBase {

    let testId: String = "0"
    let testAuthor = "Michael Diekmann"
    let testWidth: Int16 = 1544
    let testHeight: Int16 = 1024
    let testImageURL = "https://picsum.photos/id/117/154/102"
    
    let testInvalidId: Int32 = -1

    func imageFromInit() -> ImageDataModel {
        return ImageDataModel(id: testId, author: testAuthor, width: testWidth, height: testHeight, imageURL: testImageURL)
    }
    
    func testValidImageDataModel(_ image: ImageDataModel) throws {
        XCTAssertEqual(image.id, testId, "ID values not equal")
        XCTAssertEqual(image.author, testAuthor, "Author values not equal")
        XCTAssertEqual(image.width, testWidth, "Width values not equal")
        XCTAssertEqual(image.height, testHeight, "Height values not equal")
        XCTAssertEqual(image.imageURL, testImageURL, "Image URL values not equal")
    }
    
}
