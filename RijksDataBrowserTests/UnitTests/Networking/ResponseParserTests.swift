//
//  ResponseParserTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 08/11/2023.
//

@testable import RijksDataBrowser
import XCTest

final class ResponseParserTests: XCTestCase {
    
    struct TestDTO: Decodable {
        struct NestedObjectDTO: Decodable {
            var id: Int
            var value: String
        }
        
        var name: String
        var nestedObject: NestedObjectDTO
    }
    
    var parser: ResponseParserProtocol!

    override func setUpWithError() throws {
        parser = ResponseParser()
    }

    override func tearDownWithError() throws {
        parser = nil
    }

    func testSuccessfulParsing() throws {
        let jsonData = """
            {
                "name": "Lorem",
                "nestedObject": {
                    "id": 10,
                    "value": "Ipsum"
                }
            }
            """
            .data(using: .utf8)!
        
        let response: TestDTO = try parser.parseResponse(from: jsonData)
        
        XCTAssertEqual(response.name, "Lorem")
        XCTAssertEqual(response.nestedObject.id, 10)
        XCTAssertEqual(response.nestedObject.value, "Ipsum")
    }
    
    func testFailedParsing() {
        let jsonData = "not really a json".data(using: .utf8)!
        
        XCTAssertThrowsError(try parser.parseResponse(from: jsonData) as TestDTO)
    }
}
