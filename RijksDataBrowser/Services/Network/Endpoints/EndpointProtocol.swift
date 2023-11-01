//
//  EndpointProtocol.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

protocol EndpointProtocol {
    associatedtype Response: Decodable

    func makeRequest() throws -> URLRequest
    func parseResponse(from data: Data) throws -> Response
}

enum EndpointError: Error {
    case invalidData(Error)
}

extension EndpointProtocol {
    func parseResponse(from data: Data) throws -> Response {
        let decoder = JSONDecoder()
        
        let dto: Response
        do {
            dto = try decoder.decode(Response.self, from: data)
        } catch {
            throw EndpointError.invalidData(error)
        }
        
        return dto
    }
}
