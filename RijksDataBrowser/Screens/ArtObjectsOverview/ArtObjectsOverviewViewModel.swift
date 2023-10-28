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
    private let artObjectsRepository: ArtObjectsRepositoryProtocol
    private let artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    
    let updateSubject = PassthroughSubject<Void, Never>()
    
    init(
        action: @escaping (Action) -> Void,
        artObjectsRepository: ArtObjectsRepositoryProtocol,
        artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    ) {
        self.action = action
        self.artObjectsRepository = artObjectsRepository
        self.artObjectImagesRepository = artObjectImagesRepository
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
    
    private func getArtsObject(for indexPath: IndexPath) -> Collection.ArtObject {
        pagedArtObjects[indexPath.section][indexPath.row]
    }
    
    func cell(for indexPath: IndexPath) -> Cell {
        switch cellType(for: indexPath) {
        case .artObject:
            let viewModel = ArtObjectsOverviewCellViewModel(with:
                getArtsObject(for: indexPath),
                imageRepository: artObjectImagesRepository)
            return .artObject(viewModel)
        case .error:
            return .error
        case .loading:
            loadMore()
            return .loading
        case .empty:
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
            action(.showDetailsScreen(getArtsObject(for: indexPath)))
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
        artObjectsRepository.loadMore { result in
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
        artObjectsRepository.clearError()
        didEncounterError = false
    }
}
