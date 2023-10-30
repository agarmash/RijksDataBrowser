//
//  ArtObjectsSectionHeaderViewModelTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

@testable import RijksDataBrowser
import XCTest

final class ArtObjectsSectionHeaderViewModelTests: XCTestCase {
    
    var viewModel: ArtObjectsSectionHeaderViewModelProtocol!

    override func setUpWithError() throws {
        viewModel = ArtObjectsSectionHeaderViewModel(pageNumber: 5)
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testMakingTitleString() {
        XCTAssertEqual(viewModel.title, "Page 5")
    }
}
