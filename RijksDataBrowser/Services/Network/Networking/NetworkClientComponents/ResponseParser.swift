//
//  ResponseParser.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation

protocol ResponseParserProtocol {
    func parseResponse<R: Decodable>(from data: Data) throws -> R
}

enum ResponseParserError: Error {
    case responseDecodingError(DecodingError)
    case unknownError
}

class ResponseParser: ResponseParserProtocol {
    
    func parseResponse<R: Decodable>(from data: Data) throws -> R {
        let decoder = JSONDecoder()
        
        do {
            let dto = try decoder.decode(R.self, from: data)
            return dto
        } catch let error as DecodingError {
            throw ResponseParserError.responseDecodingError(error)
        } catch {
            throw ResponseParserError.unknownError
        }
    }
}
