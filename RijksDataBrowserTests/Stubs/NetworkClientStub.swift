//
//  NetworkClientStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

import Foundation
@testable import RijksDataBrowser

final class NetworkClientStub: NetworkClientProtocol {
    enum Mode {
        case passResponseDataForURL(Data, URL)
        case throwError
    }
    
    enum MockError: Error {
        case incorrectURL
        case simulatedError
    }
    
    var mode: Mode = .throwError
    
    func makeRequest<Request>(
        with endpoint: Request
    ) async throws -> Request.Response where Request: EndpointProtocol {
        switch mode {
        case let .passResponseDataForURL(data, url):
            let request = try endpoint.makeRequest()
            
            if request.url == url {
                return try endpoint.parseResponse(from: data)
            } else {
                throw MockError.incorrectURL
            }
        case .throwError:
            throw MockError.simulatedError
        }
    }
}
