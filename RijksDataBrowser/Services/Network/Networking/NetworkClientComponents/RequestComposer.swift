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

class RequestComposer: RequestComposerProtocol {
    enum Error: Swift.Error {
        case requestConstructionError
    }
    
    func composeRequest(for endpoint: some EndpointProtocol) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems

        guard
            let url = components.url
        else {
            throw Error.requestConstructionError
        }

        return URLRequest(url: url)
    }
}
