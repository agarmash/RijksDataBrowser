//
//  EndpointProtocol.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

protocol EndpointProtocol {
    associatedtype Response: Decodable

    var scheme: String? { get }
    var host: String? { get }
    var path: String { get }
    
    var queryItems: [URLQueryItem]? { get }
}
