//
//  MDTestFileBase.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/7/21.
//

import XCTest
@testable import InMotionCodeChallenge

class MDTestFileBase: XCTestCase {

    func loadJSONFile<T : RawRepresentable>(_ testFile: T) throws -> Data where T.RawValue == String {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: testFile.rawValue, ofType: "json") else
        {
            fatalError("Can't find \(testFile.rawValue) test file")
        }
        
        let retData = try Data(contentsOf: URL(fileURLWithPath: path))
        
        return retData
    }

}
