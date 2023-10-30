//
//  ArtObjectsOverviewViewModelTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

import Combine
@testable import RijksDataBrowser
import XCTest

final class ArtObjectsOverviewViewModelTests: XCTestCase {

    var artObjectsRepositoryStub: ArtObjectsRepositoryStub!
    var artObjectImagesRepositoryStub: ArtObjectImagesRepositoryStub!
    var viewModel: ArtObjectsOverviewViewModelProtocol!
    
    var emmittedAction: ArtObjectsOverviewViewModel.Action?
    
    override func setUpWithError() throws {
        artObjectsRepositoryStub = ArtObjectsRepositoryStub()
        artObjectImagesRepositoryStub = ArtObjectImagesRepositoryStub()
        
        viewModel = ArtObjectsOverviewViewModel(
            action: { [weak self] action in
                self?.emmittedAction = action
            },
            artObjectsRepository: artObjectsRepositoryStub,
            artObjectImagesRepository: artObjectImagesRepositoryStub)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        
        artObjectImagesRepositoryStub = nil
        artObjectsRepositoryStub = nil
    }

    func testLoadingFirstPage() {
        artObjectsRepositoryStub.resultsSequence = [
            .updatedObjects([[Collection.ArtObject.dummy]])
        ]
        
        let expectation = expectation(description: "testLoadingFirstPage")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        var cancellables = Set<AnyCancellable>()
        
        viewModel.snapshot.dropFirst(2).sink { snapshot in
            XCTAssertEqual(snapshot.numberOfSections, 1)
            XCTAssertEqual(snapshot.sectionIdentifiers[0], .artObjectsPage(0))
            XCTAssertEqual(snapshot.numberOfItems(inSection: .artObjectsPage(0)), 1)
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .artObjectsPage(0))[0].title,
                "River Landscape with Riders")
            
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.loadMore()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadingSecondPage() {
        artObjectsRepositoryStub.resultsSequence = [
            .updatedObjects([[Collection.ArtObject.dummy]]),
            .updatedObjects([[Collection.ArtObject.dummy], [Collection.ArtObject.dummy]])
        ]
        
        // Loading first page and waiting for it to finish
        
        let expectation1 = expectation(description: "loadingFirstPage")
        expectation1.expectedFulfillmentCount = 1
        expectation1.assertForOverFulfill = true
        
        var cancellables = Set<AnyCancellable>()
        
        viewModel.snapshot.dropFirst(2).sink { snapshot in
            XCTAssertEqual(snapshot.numberOfSections, 1)
            XCTAssertEqual(snapshot.sectionIdentifiers[0], .artObjectsPage(0))
            XCTAssertEqual(snapshot.numberOfItems(inSection: .artObjectsPage(0)), 1)
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .artObjectsPage(0))[0].title,
                "River Landscape with Riders")
            
            expectation1.fulfill()
        }.store(in: &cancellables)
        
        viewModel.loadMore()
        
        wait(for: [expectation1], timeout: 1.0)
        
        cancellables.removeAll()
        
        
        // Loading second page
        
        let expectation2 = expectation(description: "loadingSecondPage")
        expectation2.expectedFulfillmentCount = 1
        expectation2.assertForOverFulfill = true
        
        viewModel.snapshot.dropFirst(2).sink { snapshot in
            XCTAssertEqual(snapshot.numberOfSections, 2)
            XCTAssertEqual(snapshot.sectionIdentifiers[1], .artObjectsPage(1))
            XCTAssertEqual(snapshot.numberOfItems(inSection: .artObjectsPage(1)), 1)
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .artObjectsPage(1))[0].title,
                "River Landscape with Riders")
            
            expectation2.fulfill()
        }.store(in: &cancellables)
        
        viewModel.preloadArtObject(for: IndexPath(row: 0, section: 0))
        
        wait(for: [expectation2], timeout: 1.0)
    }
    
    // TODO: Cover the rest of the view model logic with tests
}
