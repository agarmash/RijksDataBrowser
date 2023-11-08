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
        case returnResponse(any Decodable)
        case throwError
    }
    
    enum MockError: Error {
        case simulatedError
    }
    
    var mode: Mode = .throwError
    
    func performRequest<E: EndpointProtocol>(with endpoint: E) async throws -> E.Response {
        switch mode {
        case .returnResponse(let response):
            return response as! E.Response
        case .throwError:
            throw MockError.simulatedError
        }
    }
}
