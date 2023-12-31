//
//  RijksCollectionDataServiceStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 24/10/2023.
//

import Foundation
@testable import RijksDataBrowser

final class RijksCollectionDataServiceStub: RijksCollectionDataServiceProtocol {
    
    enum StubAction {
        case returnItems(count: Int, itemsPerPage: Int)
        case throwAnError
    }
    
    /// Actions to take on every `getCollection` method call.
    /// If number of calls is greater that number of elements in the array,
    /// the last one is repeated for subsequent calls.
    var actionsSequence: [StubAction] = [.returnItems(count: 30, itemsPerPage: 10)]
    
    private var numberOfGetCollectionCalls = 0
    
    func getCollection(page: Int, pageSize: Int) async throws -> RijksDataBrowser.CollectionDTO {
        let index = min(numberOfGetCollectionCalls, actionsSequence.count - 1)
        numberOfGetCollectionCalls += 1
        
        switch actionsSequence[index] {
        case .returnItems(let count, let itemsPerPage):
            return CollectionDTO.makeDummy(count: count, itemsPerPage: itemsPerPage)
        case .throwAnError:
            throw RijksDataServiceError.unknownError
        }
    }
}

extension CollectionDTO {
    static func makeDummy(count: Int, itemsPerPage: Int) -> CollectionDTO {
        let artObject = CollectionDTO.ArtObjectDTO(
            objectNumber: "number1",
            title: "title1",
            webImage: CollectionDTO.ArtObjectDTO.WebImageDTO(
                url: "https://test.com/1.jpg",
                width: 400,
                height: 300))
        
        return CollectionDTO(
            count: count,
            artObjects: Array(repeating: artObject, count: itemsPerPage))
    }
}
