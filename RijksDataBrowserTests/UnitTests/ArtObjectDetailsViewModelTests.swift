//
//  ArtObjectDetailsViewModelTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

import Combine
@testable import RijksDataBrowser
import XCTest

final class ArtObjectDetailsViewModelTests: XCTestCase {
    
    var imagesRepositoryStub: ArtObjectImagesRepositoryStub!
    var collectionDetailsServiceStub: RijksCollectionDetailsDataServiceStub!
    var viewModel: ArtObjectDetailsViewModelProtocol!

    override func setUpWithError() throws {
        let artObject = Collection.ArtObject.dummy
        
        imagesRepositoryStub = ArtObjectImagesRepositoryStub()
        collectionDetailsServiceStub = RijksCollectionDetailsDataServiceStub()
        
        viewModel = ArtObjectDetailsViewModel(
            artObject: artObject,
            imagesRepository: imagesRepositoryStub,
            collectionDetailsService: collectionDetailsServiceStub)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        
        collectionDetailsServiceStub = nil
        imagesRepositoryStub = nil
    }

    func testSuccessfullyLoadingDetailsAndImage() {
        collectionDetailsServiceStub.mode = .returnValidData(CollectionDetailsDTO.dummy)
        
        let image = UIImage()
        imagesRepositoryStub.mode = .returnValidData(image)
        
        let expectation = expectation(description: "testSuccessfullyLoadingDetailsAndImage")
        expectation.expectedFulfillmentCount = 4
        expectation.assertForOverFulfill = true
        
        var cancellables = Set<AnyCancellable>()
        
        viewModel.state.dropFirst(2).sink { state in
            XCTAssertEqual(state, .presentingContent)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.title.dropFirst().sink { title in
            XCTAssertEqual(title, "River Landscape with Riders")
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.description.dropFirst().sink { description in
            XCTAssertEqual(description, "Very detailed description")
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.imageState.dropFirst(2).sink { imageState in
            XCTAssertEqual(imageState, .loaded(image))
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.loadDetails()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadingDetailsAndFailingToLoadImage() {
        collectionDetailsServiceStub.mode = .returnValidData(CollectionDetailsDTO.dummy)
        imagesRepositoryStub.mode = .throwError
        
        let expectation = expectation(description: "testLoadingDetailsAndFailingToLoadImage")
        expectation.expectedFulfillmentCount = 4
        expectation.assertForOverFulfill = true
        
        var cancellables = Set<AnyCancellable>()
        
        viewModel.state.dropFirst(2).sink { state in
            XCTAssertEqual(state, .presentingContent)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.title.dropFirst().sink { title in
            XCTAssertEqual(title, "River Landscape with Riders")
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.description.dropFirst().sink { description in
            XCTAssertEqual(description, "Very detailed description")
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.imageState.dropFirst(2).sink { imageState in
            XCTAssertEqual(imageState, .error("Unknown error"))
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.loadDetails()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailingToLoadDetails() {
        collectionDetailsServiceStub.mode = .throwError
        imagesRepositoryStub.mode = .throwError
        
        let expectation = expectation(description: "testFailingToLoadDetails")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        var cancellables = Set<AnyCancellable>()
        
        viewModel.state.dropFirst(2).sink { state in
            XCTAssertEqual(state, .error("Unknown error"))
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.loadDetails()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
