//
//  ArtObjectsOverviewViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import Foundation

enum ArtObjectsOverviewSectionType: Hashable {
    case artObjectsPage(pageNumber: Int, objects: [Collection.ArtObject])
    case loading
    case error
}

protocol ArtObjectsOverviewViewModelProtocol {
    typealias SectionType = ArtObjectsOverviewSectionType
    
    var presentationModel: CurrentValueSubject<[SectionType], Never> { get }
    
    func loadMore()
    func preloadArtObject(for indexPath: IndexPath)
    func handleTap(on indexPath: IndexPath)
    func clearError()
}

final class ArtObjectsOverviewViewModel: ArtObjectsOverviewViewModelProtocol {
    
    // MARK: - Types
    
    enum Action {
        case showDetailsScreen(Collection.ArtObject)
    }
    
    private enum ActiveSupplementaryView {
        case loading
        case error
        case none
    }

    // MARK: - Public Properties
    
    var presentationModel = CurrentValueSubject<[SectionType], Never>(.init())
    
    // MARK: - Private Properties
    
    private let action: (Action) -> Void
    
    private let artObjectsRepository: ArtObjectsRepositoryProtocol
    private let artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    
    private var pagedArtObjects: [[Collection.ArtObject]] = []
    private var hasMoreDataToLoad = true
    private var didEncounterError = false
    
    // MARK: - Init
    
    init(
        action: @escaping (Action) -> Void,
        artObjectsRepository: ArtObjectsRepositoryProtocol,
        artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    ) {
        self.action = action
        self.artObjectsRepository = artObjectsRepository
        self.artObjectImagesRepository = artObjectImagesRepository
    }
    
    // MARK: - Public Methods
    
    func handleTap(on indexPath: IndexPath) {
        switch presentationModel.value[indexPath.section] {
        case .artObjectsPage:
            let artObject = pagedArtObjects[indexPath.section][indexPath.row]
            action(.showDetailsScreen(artObject))
        default:
            return
        }
    }

    func loadMore() {
        showSupplementaryView(.loading)
        artObjectsRepository.loadMore { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .updatedObjects(let objects):
                self.pagedArtObjects = objects
                self.showLoadedObjects(objects)
            case .nothingMoreToLoad:
                self.showSupplementaryView(.none)
                self.hasMoreDataToLoad = false
            case .error:
                self.showSupplementaryView(.error)
                self.didEncounterError = true
            }
        }
    }
    
    func preloadArtObject(for indexPath: IndexPath) {
        guard
            indexPath.section < pagedArtObjects.count,
            hasMoreDataToLoad,
            !didEncounterError
        else {
            return
        }

        let page = pagedArtObjects[indexPath.section]

        if indexPath.row == page.count - 1 {
            loadMore()
        }
    }
    
    func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
    
    // MARK: - Private Methods
    
    private func showLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        let sectionsWithObjects = objects
            .enumerated()
            .map { SectionType.artObjectsPage(pageNumber: $0 + 1, objects: $1) }
        
        presentationModel.value = sectionsWithObjects
    }
    
    private func showSupplementaryView(_ supplementaryView: ActiveSupplementaryView) {
        var modelCopy = presentationModel.value
        
        modelCopy.removeAll(where: { $0 == .loading || $0 == .error })
        
        switch supplementaryView {
        case .loading:
            modelCopy.append(.loading)
        case .error:
            modelCopy.append(.error)
        case .none:
            break
        }
        
        presentationModel.value = modelCopy
    }
}
