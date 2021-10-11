//
//  CoreDataTestImage.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/9/21.
//

import XCTest
@testable import InMotionCodeChallenge

class CoreDataTestImage: CoreDataTestBase {

    func compareCDToList(_ compareImageList: [ImageDataModel]) throws -> Bool {
        var listsEqual = false
        
        // test that sorting is working as expected
        let cdSavedImages = testCDManager.fetchAllImages(sortById: true)
        guard let sortedSavedImages = cdSavedImages else {
            throw TestError.badCoreDataFetch
        }

        listsEqual = sortedSavedImages == compareImageList
        
        return listsEqual
    }
    
    func testImageList() throws {
        let data = try loadJSONFile(TestFile.testImport20Items)
        let testImages = try JSONDecoder().decode([ImageDataModel].self, from: data)
        testCDManager.addImages(testImages)
        
        // test that we get the expected amount when retrieving with no sort
        let cdSavedImages = testCDManager.fetchAllImages()
        guard let savedImages = cdSavedImages else {
            throw TestError.badCoreDataFetch
        }

        XCTAssertEqual(savedImages.count, testImages.count, "Invalid number of items in Core Data from data import")

        // test that sorting is working as expected
        var sortedTestImages = testImages.sorted(by: { $0.id < $1.id })
        var listsEqual = try compareCDToList(sortedTestImages)
       
        XCTAssertTrue(listsEqual, "List retrieved from Core Data differs from sorted import list")
        
        // test removal from single item
        let removedImage = sortedTestImages.remove(at: 5)
        testCDManager.removeImage(removedImage)
        listsEqual = try compareCDToList(sortedTestImages)
       
        XCTAssertTrue(listsEqual, "List retrieved from Core Data differs after item deletion")
        
        // test adding single item
        let testAddImage = ImageDataModel(id: "999999", author: "Michael Diekmann", width: 100, height: 100, imageURL: "testUrl")
        sortedTestImages.append(testAddImage)
        sortedTestImages = sortedTestImages.sorted(by: { $0.id < $1.id })
        testCDManager.addImage(testAddImage)
        listsEqual = try compareCDToList(sortedTestImages)
        
        XCTAssertTrue(listsEqual, "List retrieved from Core Data differs after item addition")
        
        // test updating item
        testAddImage.imageURL = "updatedTestUrl"
        testCDManager.updateImage(testAddImage)
        listsEqual = try compareCDToList(sortedTestImages)
        
        XCTAssertTrue(listsEqual, "List retrieved from Core Data differs after item update")
    }

}
