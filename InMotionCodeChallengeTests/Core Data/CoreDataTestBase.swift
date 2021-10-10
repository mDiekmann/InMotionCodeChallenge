//
//  CoreDataTestBase.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/9/21.
//

import XCTest
@testable import InMotionCodeChallenge

class CoreDataTestBase: MDTestFileBase {

    let testImportAmount = 20
    enum TestFile: String {
        case testImport20Items = "test_api_get_list_equal_to_requested_200"
    }
    
    var testCDManager: CoreDataManager!
    
    override func setUpWithError() throws {
        testCDManager = CoreDataManager(withStorageType: .inMemory)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
