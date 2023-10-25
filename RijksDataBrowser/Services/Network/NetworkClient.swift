//
//  NetworkClient.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

protocol NetworkClientProtocol {
    func makeRequest<Request>(with endpoint: Request) async throws -> Request.Response where Request: EndpointProtocol
}

final class NetworkClient: NetworkClientProtocol {
    
    // MARK: - Public Methods
    
    func makeRequest<Request>(with endpoint: Request) async throws -> Request.Response where Request: EndpointProtocol {
        let urlRequest = try endpoint.makeRequest()
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try endpoint.parseResponse(from: data)
    }
}
