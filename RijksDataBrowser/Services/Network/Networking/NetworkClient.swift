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

enum NetworkClientError: Error {
    case requestComposerError(RequestComposerError)
    case urlSessionError(URLError)
    case responseParserError(ResponseParserError)
    case unknownError
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
        do {
            let urlRequest = try requestComposer.composeRequest(for: endpoint)
            let (data, _) = try await urlSession.data(for: urlRequest)
            return try responseParser.parseResponse(from: data)
        } catch let error as RequestComposerError {
            throw NetworkClientError.requestComposerError(error)
        } catch let error as URLError {
            throw NetworkClientError.urlSessionError(error)
        } catch let error as ResponseParserError {
            throw NetworkClientError.responseParserError(error)
        } catch {
            throw NetworkClientError.unknownError
        }
    }
}
