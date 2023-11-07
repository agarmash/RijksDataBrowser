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

class ResponseParser: ResponseParserProtocol {
    enum Error: Swift.Error {
        case responseDecodingError(DecodingError)
        case unknownError
    }
    
    func parseResponse<R: Decodable>(from data: Data) throws -> R {
        let decoder = JSONDecoder()
        
        do {
            let dto = try decoder.decode(R.self, from: data)
            return dto
        } catch let error as DecodingError {
            throw Error.responseDecodingError(error)
        } catch {
            throw Error.unknownError
        }
    }
}
