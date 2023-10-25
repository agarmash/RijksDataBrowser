//
//  EndpointProtocol.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

protocol EndpointProtocol {
    associatedtype Response

    func makeRequest() throws -> URLRequest
    func parseResponse(from data: Data) throws -> Response
}
