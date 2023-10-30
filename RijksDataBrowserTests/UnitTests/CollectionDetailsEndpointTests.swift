//
//  CollectionDetailsEndpointTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

@testable import RijksDataBrowser
import XCTest

final class CollectionDetailsEndpointTests: XCTestCase {
    
    var endpoint: CollectionDetailsEndpoint!

    override func setUpWithError() throws {
        endpoint = CollectionDetailsEndpoint(objectNumber: "SK-A-4118", apiKey: "key")
    }

    override func tearDownWithError() throws {
        endpoint = nil
    }

    func testMakingRequest() {
        let request = try! endpoint.makeRequest()
        XCTAssertEqual(
            request.url,
            URL(string: "https://www.rijksmuseum.nl/api/en/collection/SK-A-4118?key=key&object-number=SK-A-4118"))
    }
    
    func testParsingResponse() {
        let json = """
        {
          "artObject": {
            "title": "River Landscape with Riders",
            "webImage": {
              "width": 2500,
              "height": 1400,
              "url": "https://eee.fff"
            },
            "description": "Very detailed description"
          }
        }
        """.data(using: .utf8)!
        
        let dto = try! endpoint.parseResponse(from: json)
        
        XCTAssertEqual(dto.artObject.title, "River Landscape with Riders")
        XCTAssertEqual(dto.artObject.description, "Very detailed description")
        XCTAssertEqual(dto.artObject.webImage.width, 2500)
        XCTAssertEqual(dto.artObject.webImage.height, 1400)
        XCTAssertEqual(dto.artObject.webImage.url, "https://eee.fff")
    }
}
