//
//  RijksCollectionDetailsDataServiceStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

import Foundation
@testable import RijksDataBrowser

final class RijksCollectionDetailsDataServiceStub: RijksCollectionDetailsDataServiceProtocol {
    
    enum Mode {
        case returnValidData(CollectionDetailsDTO)
        case throwError
    }
    
    enum MockError: Error {
        case simulatedError
    }
    
    var mode: Mode = .returnValidData(CollectionDetailsDTO.dummy)
    
    func getCollectionDetails(for objectNumber: String) async throws -> CollectionDetailsDTO {
        switch mode {
        case .returnValidData(let dto):
            return dto
        case .throwError:
            throw MockError.simulatedError
        }
    }
}
