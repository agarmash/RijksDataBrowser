//
//  URLSessionStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation
@testable import RijksDataBrowser

final class URLSessionStub: URLSessionProtocol {
    
    enum Mode {
        case returnResponseForURL((Data, URLResponse), URL)
        case throwError
    }
    
    enum MockError: Error {
        case incorrectURL
        case simulatedError
    }
    
    var mode: Mode = .throwError
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        switch mode {
        case let .returnResponseForURL(response, url):
            if request.url == url {
                return response
            } else {
                throw MockError.incorrectURL
            }
        case .throwError:
            throw MockError.simulatedError
        }
    }
}
