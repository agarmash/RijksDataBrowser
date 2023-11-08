//
//  CollectionEndpoint.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

final class CollectionEndpoint: EndpointProtocol {
    typealias Response = CollectionDTO
    
    // MARK: - Public Properties
    
    var scheme: String? { "https" }
    var host: String? { "www.rijksmuseum.nl" }
    var path: String { "/api/en/collection" }
    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "p", value: "\(page)"),
            URLQueryItem(name: "ps", value: "\(pageSize)"),
            URLQueryItem(name: "imgonly", value: "true")
        ]
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
}
