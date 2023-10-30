//
//  CollectionEndpointTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

@testable import RijksDataBrowser
import XCTest

final class CollectionEndpointTests: XCTestCase {
    
    var endpoint: CollectionEndpoint!

    override func setUpWithError() throws {
        endpoint = CollectionEndpoint(page: 3, pageSize: 10, apiKey: "key")
    }

    override func tearDownWithError() throws {
        endpoint = nil
    }

    func testMakingRequest() {
        let request = try! endpoint.makeRequest()
        XCTAssertEqual(
            request.url,
            URL(string: "https://www.rijksmuseum.nl/api/en/collection?key=key&p=3&ps=10&imgonly=true"))
    }
    
    func testParsingResponse() {
        let json = """
        {
          "count": 100,
          "artObjects": [
            {
              "objectNumber": "SK-A-4118",
              "title": "River Landscape with Riders",
              "webImage": {
                "width": 2500,
                "height": 1400,
                "url": "https://aaa.bbb"
              }
            },
            {
              "objectNumber": "SK-A-175",
              "title": "A Pelican and other Birds near a Pool",
              "webImage": {
                "width": 2300,
                "height": 2600,
                "url": "https://ccc.ddd"
              }
            }
          ]
        }
        """.data(using: .utf8)!
        
        let dto = try! endpoint.parseResponse(from: json)
        
        XCTAssertEqual(dto.count, 100)
        XCTAssertEqual(dto.artObjects.count, 2)
        
        XCTAssertEqual(dto.artObjects[0].objectNumber, "SK-A-4118")
        XCTAssertEqual(dto.artObjects[0].title, "River Landscape with Riders")
        XCTAssertEqual(dto.artObjects[0].webImage.width, 2500)
        XCTAssertEqual(dto.artObjects[0].webImage.height, 1400)
        XCTAssertEqual(dto.artObjects[0].webImage.url, "https://aaa.bbb")
        
        XCTAssertEqual(dto.artObjects[1].objectNumber, "SK-A-175")
        XCTAssertEqual(dto.artObjects[1].title, "A Pelican and other Birds near a Pool")
        XCTAssertEqual(dto.artObjects[1].webImage.width, 2300)
        XCTAssertEqual(dto.artObjects[1].webImage.height, 2600)
        XCTAssertEqual(dto.artObjects[1].webImage.url, "https://ccc.ddd")
    }
}
