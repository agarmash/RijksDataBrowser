//
//  CollectionEndpoint.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

final class CollectionEndpoint: EndpointProtocol {
    typealias Response = CollectionDTO
    
    // MARK: - Types
    
    enum CollectionEndpointError: Error {
        case invalidData(Error)
    }
    
    // MARK: - Private Properties
    
    private let page: Int
    private let pageSize: Int
    private let apiKey: String
    
    // MARK: - Init
    
    init(page: Int, pageSize: Int, apiKey: String) {
        self.page = page
        self.pageSize = pageSize
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    
    func makeRequest() throws -> URLRequest {
        let culture = "en"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.rijksmuseum.nl"
        components.path = "/api/" + culture + "/collection"
        
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "p", value: "\(page)"),
            URLQueryItem(name: "ps", value: "\(pageSize)")
        ]
        
        guard
            let url = components.url
        else {
            fatalError("URLComponents object set up incorrectly")
        }
        
        return URLRequest(url: url)
    }
    
    func parseResponse(from data: Data) throws -> CollectionDTO {
        let decoder = JSONDecoder()
        
        let dto: CollectionDTO
        do {
            dto = try decoder.decode(CollectionDTO.self, from: data)
        } catch {
            throw CollectionEndpointError.invalidData(error)
        }
        
        return dto
    }
}
