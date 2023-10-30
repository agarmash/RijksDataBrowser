//
//  CollectionDetailsEndpoint.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

final class CollectionDetailsEndpoint: EndpointProtocol {
    typealias Response = CollectionDetailsDTO
    
    // MARK: - Types
    
    enum CollectionDetailsEndpointError: Error {
        case invalidData(Error)
    }
    
    // MARK: - Private Properties
        
    private let objectNumber: String
    private let apiKey: String
    
    // MARK: - Init
    
    init(objectNumber: String, apiKey: String) {
        self.objectNumber = objectNumber
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    
    func makeRequest() throws -> URLRequest {
        let culture = "en"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.rijksmuseum.nl"
        components.path = "/api/" + culture + "/collection/" + objectNumber
        
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "object-number", value: objectNumber),
        ]
        
        guard
            let url = components.url
        else {
            fatalError("URLComponents object set up incorrectly")
        }
        
        return URLRequest(url: url)
    }
    
    func parseResponse(from data: Data) throws -> CollectionDetailsDTO {
        let decoder = JSONDecoder()
        
        let dto: CollectionDetailsDTO
        do {
            dto = try decoder.decode(CollectionDetailsDTO.self, from: data)
        } catch {
            throw CollectionDetailsEndpointError.invalidData(error)
        }
        
        return dto
    }
}
