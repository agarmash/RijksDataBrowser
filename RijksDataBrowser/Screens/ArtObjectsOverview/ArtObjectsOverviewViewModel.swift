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
    
    private var hasMoreDataToLoad = true
    private var didEncounterError = false
    
    private var numberOfLoadedPages = 0
    private var numberOfItemsInLastPage = 0
    
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
        case let .artObjectsPage(pageNumber: _, objects: artObjects):
            let artObject = artObjects[indexPath.row]
            action(.showDetailsScreen(artObject))
        default:
            return
        }
    }
    
    func loadMore() {
        clearError()
        loadNextPage()
    }

    func loadNextPage() {
        showSupplementaryView(.loading)
        artObjectsRepository.loadMore { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .updatedObjects(let objects):
                self.processLoadedObjects(objects)
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
        if
            hasMoreDataToLoad,
            !didEncounterError,
            indexPath.section == numberOfLoadedPages - 1,
            indexPath.row == numberOfItemsInLastPage - 1
        {
            loadNextPage()
        }
    }
    
    // MARK: - Private Methods
    
    private func processLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        numberOfLoadedPages = objects.count
        numberOfItemsInLastPage = objects.last?.count ?? 0
        
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
    
    private func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
}
