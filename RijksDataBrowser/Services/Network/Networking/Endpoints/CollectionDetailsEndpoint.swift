//
//  CollectionDetailsEndpoint.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

final class CollectionDetailsEndpoint: EndpointProtocol {
    typealias Response = CollectionDetailsDTO
    
    // MARK: - Public Properties
    
    var scheme: String? { "https" }
    var host: String? { "www.rijksmuseum.nl" }
    var path: String { "/api/en/collection/" + objectNumber }
    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "object-number", value: objectNumber),
        ]
    }
    
    // MARK: - Private Properties
        
    private let objectNumber: String
    private let apiKey: String
    
    // MARK: - Init
    
    init(objectNumber: String, apiKey: String) {
        self.objectNumber = objectNumber
        self.apiKey = apiKey
    }
}
