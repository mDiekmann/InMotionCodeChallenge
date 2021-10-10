//
//  MDTestFileBase.swift
//  InMotionCodeChallengeTests
//
//  Created by Michael Diekmann on 10/7/21.
//

import XCTest
@testable import InMotionCodeChallenge

enum TestError: Error, Equatable {
    case fileNotFound(String)
    case invalidURLForRequest(String)
    case badCoreDataFetch
}

extension TestError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .fileNotFound(let fileName):
                return "Unable to find file: \(fileName)"
            case .invalidURLForRequest(let requestType):
                return "Invalid URL for request type \(requestType)"
            case .badCoreDataFetch:
                return "Error when retrieving data from Core Data"
        }
    }
}

class MDTestFileBase: XCTestCase {

    func loadJSONFile<T : RawRepresentable>(_ testFile: T) throws -> Data where T.RawValue == String {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: testFile.rawValue, ofType: "json") else {
            throw TestError.fileNotFound(testFile.rawValue)
        }
        
        let retData = try Data(contentsOf: URL(fileURLWithPath: path))
        
        return retData
    }

}
