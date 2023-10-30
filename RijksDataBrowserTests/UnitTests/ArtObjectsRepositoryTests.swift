//
//  ArtObjectsRepositoryTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 24/10/2023.
//

@testable import RijksDataBrowser
import XCTest

final class ArtObjectsRepositoryTests: XCTestCase {
    
    var dataServiceStub: RijksCollectionDataServiceStub!
    var artObjectRepository: ArtObjectsRepositoryProtocol!

    override func setUpWithError() throws {
        dataServiceStub = RijksCollectionDataServiceStub()
        artObjectRepository = ArtObjectsRepository(dataService: dataServiceStub)
    }

    override func tearDownWithError() throws {
        artObjectRepository = nil
        dataServiceStub = nil
    }
    
    func testHappyPath() {
        dataServiceStub.actionsSequence = [.returnItems(count: 18, itemsPerPage: 10)]
        
        let expectation = expectation(description: "")
        expectation.expectedFulfillmentCount = 3
        
        artObjectRepository.loadMore { result in
            switch result {
            case .updatedObjects(let artObjects):
                XCTAssertEqual(artObjects.count, 1)
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
        
        artObjectRepository.loadMore { result in
            switch result {
            case .updatedObjects(let artObjects):
                XCTAssertEqual(artObjects.count, 2)
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
        
        artObjectRepository.loadMore { result in
            switch result {
            case .nothingMoreToLoad:
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testHandlingError() {
        let expectation = expectation(description: "")
        expectation.expectedFulfillmentCount = 5
        
        dataServiceStub.actionsSequence = [
            .returnItems(count: 18, itemsPerPage: 10),
            .throwAnError,
            .returnItems(count: 18, itemsPerPage: 10)
        ]
        
        artObjectRepository.loadMore { result in
            switch result {
            case .updatedObjects(let artObjects):
                XCTAssertEqual(artObjects.count, 1)
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
        
        artObjectRepository.loadMore { result in
            switch result {
            case .error(let error):
                XCTAssertEqual(error, .networkError(URLError(.cannotConnectToHost)))
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
            
        artObjectRepository.loadMore { result in
            switch result {
            case .error(let error):
                XCTAssertEqual(error, .previousErrorHasntBeenCleared)
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
            
        artObjectRepository.clearError()
        
        artObjectRepository.loadMore { result in
            switch result {
            case .updatedObjects(let artObjects):
                XCTAssertEqual(artObjects.count, 2)
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
        
        artObjectRepository.loadMore { result in
            switch result {
            case .nothingMoreToLoad:
                expectation.fulfill()
            default:
                XCTFail("")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
