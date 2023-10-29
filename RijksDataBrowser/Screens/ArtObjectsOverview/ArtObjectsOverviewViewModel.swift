//
//  ArtObjectsOverviewViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import UIKit

final class ArtObjectsOverviewViewModel {
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, Collection.ArtObject> = .init()
    
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
    let artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    
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
    
    private func getArtsObject(for indexPath: IndexPath) -> Collection.ArtObject {
        pagedArtObjects[indexPath.section][indexPath.row]
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
    
    func loadMore() {
        artObjectsRepository.loadMore { result in
            switch result {
            case .updatedObjects(let objects):
                self.pagedArtObjects = objects
                self.handleLoadedObjects(objects)
            case .nothingMoreToLoad:
                self.hasMoreDataToLoad = false
            case .error:
                self.didEncounterError = true
            }

            self.updateSubject.send()
        }
    }
    
    func handleLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Collection.ArtObject>()
        
        let sections = [Int](objects.indices)
        
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(objects[section], toSection: section)
        }
        snapshot.appendSections([99])
        
        self.snapshot = snapshot
    }
    
    private func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
    
    
}
