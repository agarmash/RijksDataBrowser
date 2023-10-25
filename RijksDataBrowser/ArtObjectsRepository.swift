//
//  ArtObjectsRepository.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import AsyncAlgorithms
import Foundation

protocol ArtObjectsRepositoryProtocol {
    func loadMore(completion: @escaping (ArtObjectsRepository.Result) -> Void)
    func clearError()
}

final class ArtObjectsRepository: ArtObjectsRepositoryProtocol {
    
    public enum Result {
        case updatedObjects([[Collection.ArtObject]])
        case nothingMoreToLoad
        case error(ArtObjectsRepositoryError)
    }
    
    public enum ArtObjectsRepositoryError: Error {
        case previousErrorHasntBeenCleared
//        case networkError(Error)
        case networkError
    }
    
    // API Constants
    private let pageSize = 20
    private let countThreshold = 10_000
    
    // Accumulated result
    private var artObjectsCount: Int?
    private var loadedArtObjectsCount = 0
    private var pagedArtObjects: [[Collection.ArtObject]] = []
    
    // Error flag
    private var didEncounterError = false
    
    // Dependencies
    private let dataService: RijksCollectionDataServiceProtocol
    
    // Private queues
    private let apiCallsQueue = DispatchQueue(label: "APICallsQueue")
    
    init(dataService: RijksCollectionDataServiceProtocol) {
        self.dataService = dataService
    }
    
    private func canLoadMore() -> Bool {
        guard
            let artObjectsCount = artObjectsCount
        else {
            return true // state when nothing has been loaded so far
        }
        
        return loadedArtObjectsCount < min(countThreshold, artObjectsCount)
    }
    
    func loadMore(completion: @escaping (ArtObjectsRepository.Result) -> Void) {
        apiCallsQueue.async {
            guard
                self.canLoadMore()
            else {
                completion(.nothingMoreToLoad)
                return
            }
            
            guard
                !self.didEncounterError
            else {
                completion(.error(.previousErrorHasntBeenCleared))
                return
            }
                
            let semaphore = DispatchSemaphore(value: 0)
            
            Task {
                do {
                    
                    let pageNumber = self.pagedArtObjects.count + 1
                    
                    let newPage = try await self
                        .dataService
                        .getCollection(
                            page: self.pagedArtObjects.count,
                            pageSize: self.pageSize)
                        .toDomain()
                    
                    self.pagedArtObjects.append(newPage.artObjects)
                    
                    self.artObjectsCount = self.artObjectsCount ?? newPage.count
                    self.loadedArtObjectsCount += newPage.artObjects.count
                    
                    completion(.updatedObjects(self.pagedArtObjects))
                } catch {
                    self.didEncounterError = true
                    
//                    completion(.error(.networkError(error)))
                    completion(.error(.networkError))
                }
                
                semaphore.signal()
            }
            
            semaphore.wait()
        }
    }
    
    func clearError() {
        apiCallsQueue.async {
            // Clear the error on the same queue so all the possible
            // subsequent dispatch blocks are cancelled
            self.didEncounterError = false
        }
    }
}
