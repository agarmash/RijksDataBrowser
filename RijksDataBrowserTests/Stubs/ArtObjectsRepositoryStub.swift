//
//  ArtObjectsRepositoryStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

import Foundation
@testable import RijksDataBrowser

final class ArtObjectsRepositoryStub: ArtObjectsRepositoryProtocol {
    
    /// Results to send on every `loadMore` method call.
    /// If number of calls is greater that number of elements in the array,
    /// the last one is repeated for subsequent calls.
    var resultsSequence: [ArtObjectsRepositoryResult] = [.nothingMoreToLoad]
    var numberOfLoadMoreCalls = 0
    
    var didCallClearError = false
    
    func loadMore(completion: @escaping (ArtObjectsRepositoryResult) -> Void) {
        let index = min(numberOfLoadMoreCalls, resultsSequence.count - 1)
        numberOfLoadMoreCalls += 1
        
        completion(resultsSequence[index])
    }
    
    func clearError() {
        didCallClearError = true
    }
}
