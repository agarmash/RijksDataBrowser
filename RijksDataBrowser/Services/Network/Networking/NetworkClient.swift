//
//  NetworkClient.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

protocol NetworkClientProtocol {
    func performRequest<E: EndpointProtocol>(with endpoint: E) async throws -> E.Response
}

final class NetworkClient: NetworkClientProtocol {

    // MARK: - Private Properties
    
    private let requestComposer: RequestComposerProtocol
    private let urlSession: URLSessionProtocol
    private let responseParser: ResponseParserProtocol
    
    // MARK: - Init
    
    init(
        requestComposer: RequestComposerProtocol,
        urlSession: URLSessionProtocol,
        responseParser: ResponseParserProtocol
    ) {
        self.requestComposer = requestComposer
        self.urlSession = urlSession
        self.responseParser = responseParser
    }
    
    // MARK: - Public Methods
    
    func performRequest<E: EndpointProtocol>(with endpoint: E) async throws -> E.Response {
        let urlRequest = try requestComposer.composeRequest(for: endpoint)
        let (data, _) = try await urlSession.data(for: urlRequest)
        return try responseParser.parseResponse(from: data)
    }
}
