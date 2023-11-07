//
//  URLSession.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
