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

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class NetworkClient: NetworkClientProtocol {
    
    // MARK: - Types
    
    enum Error: Swift.Error {
        case responceDecodingError(DecodingError)
    }
    
    // MARK: - Private Properties
    
    private let urlSession: URLSessionProtocol
    
    // MARK: - Init
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Public Methods
    
    func makeRequest<Request>(with endpoint: Request) async throws -> Request.Response where Request: EndpointProtocol {
        let urlRequest = try endpoint.makeRequest()
        let (data, _) = try await urlSession.data(for: urlRequest)
        return try parseResponse(from: data, responceType: Request.Response.self)
    }
    
    private func parseResponse<Response: Decodable>(
        from data: Data,
        responceType: Response.Type
    ) throws -> Response {
        let decoder = JSONDecoder()
        
        let dto: Response
        do {
            dto = try decoder.decode(Response.self, from: data)
        } catch let error as DecodingError {
            throw Error.responceDecodingError(error)
        }
        
        return dto
    }
}
