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

        viewModel.presentationModel.dropFirst(2).sink { snapshot in
            XCTAssertEqual(snapshot.count, 1)
            XCTAssertEqual(snapshot[0], .artObjectsPage(pageNumber: 1, objects: [Collection.ArtObject.dummy]))

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

        viewModel.presentationModel.dropFirst(2).sink { snapshot in
            XCTAssertEqual(snapshot.count, 1)
            XCTAssertEqual(snapshot[0], .artObjectsPage(pageNumber: 1, objects: [Collection.ArtObject.dummy]))

            expectation1.fulfill()
        }.store(in: &cancellables)

        viewModel.loadMore()

        wait(for: [expectation1], timeout: 1.0)

        cancellables.removeAll()


        // Loading second page

        let expectation2 = expectation(description: "loadingSecondPage")
        expectation2.expectedFulfillmentCount = 1
        expectation2.assertForOverFulfill = true

        viewModel.presentationModel.dropFirst(2).sink { snapshot in
            XCTAssertEqual(snapshot.count, 2)
            XCTAssertEqual(snapshot[1], .artObjectsPage(pageNumber: 2, objects: [Collection.ArtObject.dummy]))
            
            expectation2.fulfill()
        }.store(in: &cancellables)

        viewModel.preloadArtObject(for: IndexPath(row: 0, section: 0))

        wait(for: [expectation2], timeout: 1.0)
    }

    // TODO: Cover the rest of the view model logic with tests
}
