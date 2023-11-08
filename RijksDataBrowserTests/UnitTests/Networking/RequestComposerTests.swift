//
//  RequestComposerTests.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 08/11/2023.
//

@testable import RijksDataBrowser
import XCTest

final class RequestComposerTests: XCTestCase {
    
    var composer: RequestComposerProtocol!

    override func setUpWithError() throws {
        composer = RequestComposer()
    }

    override func tearDownWithError() throws {
        composer = nil
    }
    
    func testSuccessfulRequestComposing() {
        do {
            let request = try composer.composeRequest(for: ValidTestEndpoint())
            XCTAssertEqual(request.url?.absoluteString, "https://hostname.com/path/to/resource?id=123")
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testFailingRequestComposing() {
        XCTAssertThrowsError(try composer.composeRequest(for: InvalidTestEndpoint()))
    }
}

struct ValidTestEndpoint: EndpointProtocol {
    typealias Response = String
    
    let scheme: String? = "https"
    let host: String? = "hostname.com"
    let path: String = "/path/to/resource"
    let queryItems: [URLQueryItem]? = [
        URLQueryItem(name: "id", value: "123")
    ]
}

struct InvalidTestEndpoint: EndpointProtocol {
    typealias Response = String
    
    let scheme: String? = "https"
    let host: String? = nil
    let path: String = "//path/to/resource"
    let queryItems: [URLQueryItem]? = nil
}
