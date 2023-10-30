//
//  RijksDataService.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

protocol RijksCollectionDataServiceProtocol {
    func getCollection(page: Int, pageSize: Int) async throws -> CollectionDTO
}

protocol RijksCollectionDetailsDataServiceProtocol {
    func getCollectionDetails(for objectNumber: String) async throws -> CollectionDetailsDTO
}

final class RijksDataService: RijksCollectionDataServiceProtocol, RijksCollectionDetailsDataServiceProtocol {
    
    // MARK: - Private Properties
    
    private let client: NetworkClientProtocol
    private let apiKey = "0fiuZFh4"
    
    // MARK: - Init
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    // MARK: - Public Methods
    
    func getCollection(page: Int, pageSize: Int) async throws -> CollectionDTO {
        let endpoint = CollectionEndpoint(page: page, pageSize: pageSize, apiKey: apiKey)
        
        return try await client.makeRequest(with: endpoint)
    }
    
    func getCollectionDetails(for objectNumber: String) async throws -> CollectionDetailsDTO {
        let endpoint = CollectionDetailsEndpoint(objectNumber: objectNumber, apiKey: apiKey)
        
        return try await client.makeRequest(with: endpoint)
    }
}
