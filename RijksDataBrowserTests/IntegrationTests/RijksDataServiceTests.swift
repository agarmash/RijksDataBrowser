//
//  RijksDataServiceTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

@testable import RijksDataBrowser
import XCTest

final class RijksDataServiceTests: XCTestCase {
    
    var networkClientStub: NetworkClientStub!
    var service: RijksDataService!

    override func setUpWithError() throws {
        networkClientStub = NetworkClientStub()
        service = RijksDataService(client: networkClientStub)
    }

    override func tearDownWithError() throws {
        service = nil
        networkClientStub = nil
    }

    func testSuccessfullyGettingCollection() async {
        let requestURL = URL(string: "https://www.rijksmuseum.nl/api/en/collection?key=0fiuZFh4&p=3&ps=10")!
        let responseData = """
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
        
        networkClientStub.mode = .passResponseDataForURL(responseData, requestURL)
        
        do {
            let collection = try await service.getCollection(page: 3, pageSize: 10)
            XCTAssertEqual(collection.artObjects.count, 2)
        } catch {
            XCTFail("Error shoudn't be caught in this test")
        }
    }
    
    func testInvalidRequestURLForGettingCollection() async {
        let requestURL = URL(string: "https://invalid.url")!
        let responseData = """
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
        
        networkClientStub.mode = .passResponseDataForURL(responseData, requestURL)
        
        do {
            _ = try await service.getCollection(page: 3, pageSize: 10)
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? NetworkClientStub.MockError, NetworkClientStub.MockError.incorrectURL)
        }
    }
    
    func testNetworkErrorForGettingCollection() async {
        networkClientStub.mode = .throwError
        
        do {
            _ = try await service.getCollection(page: 3, pageSize: 10)
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? NetworkClientStub.MockError, NetworkClientStub.MockError.simulatedError)
        }
    }
    
    func testSuccessfullyGettingCollectionDetails() async {
        let requestURL = URL(string: "https://www.rijksmuseum.nl/api/en/collection/SK-A-4118?key=0fiuZFh4&object-number=SK-A-4118")!
        let responseData = """
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
        
        networkClientStub.mode = .passResponseDataForURL(responseData, requestURL)
        
        do {
            let details = try await service.getCollectionDetails(for: "SK-A-4118")
            XCTAssertEqual(details.artObject.title, "River Landscape with Riders")
        } catch {
            XCTFail("Error shoudn't be caught in this test")
        }
    }
    
    func testInvalidRequestURLForGettingCollectionDetails() async {
        let requestURL = URL(string: "https://invalid.url")!
        let responseData = """
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
        
        networkClientStub.mode = .passResponseDataForURL(responseData, requestURL)
        
        do {
            _ = try await service.getCollectionDetails(for: "SK-A-4118")
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? NetworkClientStub.MockError, NetworkClientStub.MockError.incorrectURL)
        }
    }
    
    func testNetworkErrorForGettingCollectionDetails() async {
        networkClientStub.mode = .throwError
        
        do {
            _ = try await service.getCollectionDetails(for: "SK-A-4118")
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? NetworkClientStub.MockError, NetworkClientStub.MockError.simulatedError)
        }
    }
}
