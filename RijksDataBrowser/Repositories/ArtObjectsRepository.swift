//
//  ArtObjectsRepository.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

enum ArtObjectsRepositoryResult {
    case updatedObjects([[Collection.ArtObject]])
    case nothingMoreToLoad
    case error(Error)
}

protocol ArtObjectsRepositoryProtocol {
    typealias Result = ArtObjectsRepositoryResult
    
    func loadMore(completion: @escaping (Result) -> Void)
    func clearError()
}

final class ArtObjectsRepository: ArtObjectsRepositoryProtocol {
    
    // MARK: - Types
    
    enum Error: Swift.Error {
        case previousErrorHasntBeenCleared
        case networkError(URLError)
    }
    
    // MARK: - Private Properties
    
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
    
    // MARK: - Init
    
    init(dataService: RijksCollectionDataServiceProtocol) {
        self.dataService = dataService
    }
    
    // MARK: - Public Methods
    
    func loadMore(completion: @escaping (ArtObjectsRepository.Result) -> Void) {
        apiCallsQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard
                self.canLoadMore()
            else {
                completion(.nothingMoreToLoad)
                return
            }
            
            guard
                !self.didEncounterError
            else {
                completion(.error(Error.previousErrorHasntBeenCleared))
                return
            }
                
            let semaphore = DispatchSemaphore(value: 0)
            
            Task {
                do {
                    let newPage = try await self
                        .dataService
                        .getCollection(
                            page: self.getNextPageNumber(),
                            pageSize: self.pageSize)
                        .toDomain()
                    
                    self.pagedArtObjects.append(newPage.artObjects)
                    
                    self.artObjectsCount = self.artObjectsCount ?? newPage.count
                    self.loadedArtObjectsCount += newPage.artObjects.count
                    
                    completion(.updatedObjects(self.pagedArtObjects))
                } catch let error as URLError {
                    self.didEncounterError = true
                    
                    completion(.error(Error.networkError(error)))
                }
                
                semaphore.signal()
            }
            
            semaphore.wait()
        }
    }
    
    func clearError() {
        apiCallsQueue.async { [weak self] in
            // Clear the error on the same queue so all the possible
            // subsequent dispatch blocks are cancelled
            self?.didEncounterError = false
        }
    }
    
    // MARK: - Private Methods
    
    private func canLoadMore() -> Bool {
        guard
            let artObjectsCount = artObjectsCount
        else {
            return true // state when nothing has been loaded so far
        }
        
        return loadedArtObjectsCount < min(countThreshold, artObjectsCount)
    }
    
    private func getNextPageNumber() -> Int {
        // Turns out that the API expects page numbers to start from 1.
        // Response for index 0 is equal to the one for index 1.
        self.pagedArtObjects.count + 1
    }
}

extension ArtObjectsRepository.Error: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.previousErrorHasntBeenCleared, .previousErrorHasntBeenCleared):
            return true
        case (.networkError(let lError), .networkError(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}
