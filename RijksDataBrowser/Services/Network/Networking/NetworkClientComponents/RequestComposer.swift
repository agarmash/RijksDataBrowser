//
//  RequestComposer.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation

protocol RequestComposerProtocol {
    func composeRequest(for endpoint: some EndpointProtocol) throws -> URLRequest
}

enum RequestComposerError: Error {
    case requestConstructionError
}

class RequestComposer: RequestComposerProtocol {
    
    // MARK: - Public Methods
    
    func composeRequest(for endpoint: some EndpointProtocol) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems

        guard
            let url = components.url
        else {
            throw RequestComposerError.requestConstructionError
        }

        return URLRequest(url: url)
    }
}
