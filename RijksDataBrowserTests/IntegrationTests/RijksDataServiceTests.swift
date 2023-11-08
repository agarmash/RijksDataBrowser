//
//  RijksDataServiceTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

@testable import RijksDataBrowser
import XCTest

final class RijksDataServiceTests: XCTestCase {

    var urlSessionStub: URLSessionStub!
    var networkClient: NetworkClient!
    var service: RijksDataService!

    override func setUpWithError() throws {
        urlSessionStub = URLSessionStub()
        
        networkClient = NetworkClient(
            requestComposer: RequestComposer(),
            urlSession: urlSessionStub,
            responseParser: ResponseParser())
        
        service = RijksDataService(client: networkClient)
    }

    override func tearDownWithError() throws {
        service = nil
        networkClient = nil
        urlSessionStub = nil
    }

    func testSuccessfullyGettingCollection() async {
        let requestURL = URL(string: "https://www.rijksmuseum.nl/api/en/collection?key=0fiuZFh4&p=3&ps=10&imgonly=true")!
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

        urlSessionStub.mode = .returnResponseForURL((responseData, URLResponse()), requestURL)

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

        urlSessionStub.mode = .returnResponseForURL((responseData, URLResponse()), requestURL)

        do {
            _ = try await service.getCollection(page: 3, pageSize: 10)
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? URLSessionStub.MockError, URLSessionStub.MockError.incorrectURL)
        }
    }

    func testNetworkErrorForGettingCollection() async {
        urlSessionStub.mode = .throwError

        do {
            _ = try await service.getCollection(page: 3, pageSize: 10)
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? URLSessionStub.MockError, URLSessionStub.MockError.simulatedError)
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

        urlSessionStub.mode = .returnResponseForURL((responseData, URLResponse()), requestURL)

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

        urlSessionStub.mode = .returnResponseForURL((responseData, URLResponse()), requestURL)

        do {
            _ = try await service.getCollectionDetails(for: "SK-A-4118")
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? URLSessionStub.MockError, URLSessionStub.MockError.incorrectURL)
        }
    }

    func testNetworkErrorForGettingCollectionDetails() async {
        urlSessionStub.mode = .throwError

        do {
            _ = try await service.getCollectionDetails(for: "SK-A-4118")
            XCTFail("Code flow shouldn't reach here")
        } catch {
            XCTAssertEqual(error as? URLSessionStub.MockError, URLSessionStub.MockError.simulatedError)
        }
    }
}
