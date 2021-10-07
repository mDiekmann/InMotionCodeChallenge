//
//  ImageCoreDataTest.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/7/21.
//

import XCTest
import CoreData
@testable import InMotionCodeChallenge

class ImageCoreDataTest: ImageTestBase {
    // need a context to create Image objects
    var coreDataManager: CoreDataManager?
    
    override func setUpWithError() throws {
        coreDataManager = CoreDataManager.init(withStorageType: .inMemory)
    }
    
    func getTestContext() throws -> NSManagedObjectContext {
        let context = coreDataManager?.managedObjectContext
        XCTAssertNotNil(context, "Testing oontext is nil")
        
        return context!
    }
    
    // MARK: ManagedObjectConvertible testing
    func testImageToObject() throws {
        let context = try getTestContext()
        
        let cdImage = Image(context: context)
        cdImage.id = testId
        cdImage.author = testAuthor
        cdImage.width = testWidth
        cdImage.height = testHeight
        cdImage.imageUrl = testImageURL
        
        let imageFromCD = cdImage.toObject()
        
        try testValidImageDataModel(imageFromCD)
    }
    
    func testImageFromObject() throws {
        let context = try getTestContext()
        
        let testImage = imageFromInit()
        let cdImage = Image(context: context)
        cdImage.from(object: testImage)
        
        XCTAssertEqual(cdImage.id, testId, "ID values not equal")
        XCTAssertEqual(cdImage.author, testAuthor, "Author values not equal")
        XCTAssertEqual(cdImage.width, testWidth, "Width values not equal")
        XCTAssertEqual(cdImage.height, testHeight, "Height values not equal")
        XCTAssertEqual(cdImage.imageUrl, testImageURL, "Image URL values not equal")
    }
}
