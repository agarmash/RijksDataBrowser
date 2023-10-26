//
//  ArtObjectsOverviewViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import UIKit

final class ArtObjectsOverviewViewModel {
    enum Cell {
        case empty
        case loading
        case artObject(ArtObjectsOverviewCellViewModel)
        case error
    }
    
    enum CellType {
        case empty
        case loading
        case artObject
        case error
    }
    
    enum Action {
        case showDetailsScreen(Collection.ArtObject)
    }
    
    private let action: (Action) -> Void
    private let repository: ArtObjectsRepositoryProtocol
    
    let updateSubject = PassthroughSubject<Void, Never>()
    
    init(
        action: @escaping (Action) -> Void,
        repository: ArtObjectsRepositoryProtocol
    ) {
        self.action = action
        self.repository = repository
    }
    
    private var pagedArtObjects: [[Collection.ArtObject]] = []
    private var hasMoreDataToLoad = true
    private var didEncounterError = false
    
    private func shouldDisplayExtraSectionWithCell() -> Bool {
        hasMoreDataToLoad || didEncounterError
    }
    
    func numberOfSections() -> Int {
        let extraSectionsCount = shouldDisplayExtraSectionWithCell() ? 1 : 0
        return pagedArtObjects.count + extraSectionsCount
    }
    
    func numberOfRowsInSection(index: Int) -> Int {
        if index < pagedArtObjects.count {
            return pagedArtObjects[index].count
        } else if shouldDisplayExtraSectionWithCell() {
            return 1
        } else {
            return 0
        }
    }
    
    func cell(for indexPath: IndexPath) -> Cell {
        if indexPath.section < pagedArtObjects.count {
            return .artObject(ArtObjectsOverviewCellViewModel(with:
                pagedArtObjects[indexPath.section][indexPath.row],
                imageRepository: ArtObjectImagesRepository(targetImageWidth: 400, imageLoader: ImageLoaderService())))
        } else if didEncounterError {
            return .error
        } else if hasMoreDataToLoad {
            loadMore()
            return .loading
        } else {
            return .empty
        }
    }
    
    func cellType(for indexPath: IndexPath) -> CellType {
        if indexPath.section < pagedArtObjects.count {
            return .artObject
        } else if didEncounterError {
            return .error
        } else if hasMoreDataToLoad {
            return .loading
        } else {
            return .empty
        }
    }
    
    func handleTap(on indexPath: IndexPath) {
        switch cellType(for: indexPath) {
        case .artObject:
            action(.showDetailsScreen(pagedArtObjects[indexPath.section][indexPath.row]))
        case .error:
            clearError()
            loadMore()
            updateSubject.send()
        default:
            return
        }
    }
    
    func headerViewModel(for indexPath: IndexPath) -> HeaderViewModel {
        HeaderViewModel(pageNumber: indexPath.section + 1)
    }
    
    private func loadMore() {
        repository.loadMore { result in
            switch result {
            case .updatedObjects(let objects):
                self.pagedArtObjects = objects
            case .nothingMoreToLoad:
                self.hasMoreDataToLoad = false
            case .error:
                self.didEncounterError = true
            }
            
            self.updateSubject.send()
        }
    }
    
    private func clearError() {
        repository.clearError()
        didEncounterError = false
    }
}
