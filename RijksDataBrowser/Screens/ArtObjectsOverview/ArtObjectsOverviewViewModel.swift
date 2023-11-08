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

enum ArtObjectsOverviewHeaderType {
    case artObjectsPage(ArtObjectsSectionHeaderViewModelProtocol)
    case loading
    case error(ErrorSectionHeaderViewModelProtocol)
}

enum ArtObjectsOverviewCellType {
    case object(ArtObjectsOverviewCellViewModelProtocol)
    case none
}

protocol ArtObjectsOverviewViewModelProtocol {
    typealias SectionType = ArtObjectsOverviewSectionType
    typealias HeaderType = ArtObjectsOverviewHeaderType
    typealias CellType = ArtObjectsOverviewCellType
    
    var presentationModel: CurrentValueSubject<[SectionType], Never> { get }
    
    func loadMore()
    func preloadArtObject(for indexPath: IndexPath)
    func makeHeader(for indexPath: IndexPath) -> HeaderType
    func makeCell(for indexPath: IndexPath) -> CellType
    func handleTap(on indexPath: IndexPath)
}

final class ArtObjectsOverviewViewModel: ArtObjectsOverviewViewModelProtocol {
    
    // MARK: - Types
    
    enum Action {
        case showDetailsScreen(Collection.ArtObject)
    }

    // MARK: - Public Properties
    
    var presentationModel = CurrentValueSubject<[SectionType], Never>(.init())
    
    // MARK: - Private Properties
    
    private let action: (Action) -> Void
    
    private let artObjectsRepository: ArtObjectsRepositoryProtocol
    private let artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    
    private let mapper: ArtObjectsOverviewViewModelMapperProtocol
    
    private var pagedArtObjects: [[Collection.ArtObject]] = []
    private var hasMoreDataToLoad = true
    private var didEncounterError = false
    
    // MARK: - Init
    
    init(
        action: @escaping (Action) -> Void,
        artObjectsRepository: ArtObjectsRepositoryProtocol,
        artObjectImagesRepository: ArtObjectImagesRepositoryProtocol,
        mapper: ArtObjectsOverviewViewModelMapperProtocol
    ) {
        self.action = action
        self.artObjectsRepository = artObjectsRepository
        self.artObjectImagesRepository = artObjectImagesRepository
        self.mapper = mapper
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
        showLoader()
        artObjectsRepository.loadMore { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .updatedObjects(let objects):
                self.pagedArtObjects = objects
                self.showLoadedObjects(objects)
            case .nothingMoreToLoad:
                self.removeStatusViews()
                self.hasMoreDataToLoad = false
            case .error:
                self.showError()
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
    
    func makeHeader(for indexPath: IndexPath) -> HeaderType {
        switch presentationModel.value[indexPath.section] {
        case .artObjectsPage(let pageNumber, _):
            let viewModel = mapper.makePageHeaderViewModel(pageNumber: pageNumber + 1)
            return .artObjectsPage(viewModel)
        case .loading:
            return .loading
        case .error:
            let viewModel = mapper.makeErrorHeaderViewModel(didTapOnView: { [weak self] in
                self?.clearError()
                self?.loadMore()
            })
            return .error(viewModel)
        }
    }
    
    func makeCell(for indexPath: IndexPath) -> CellType {
        switch presentationModel.value[indexPath.section] {
        case .artObjectsPage:
            let artObject = pagedArtObjects[indexPath.section][indexPath.row]
            let viewModel =  mapper.makeArtObjectCellViewModel(
                with: artObject,
                imageRepository: artObjectImagesRepository)
            return .object(viewModel)
        default:
            return .none
        }
    }
    
    // MARK: - Private Methods
    
    private func showLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        let sectionsWithObjects = objects
            .enumerated()
            .map { SectionType.artObjectsPage(pageNumber: $0, objects: $1) }
        presentationModel.value = sectionsWithObjects
    }
    
    private func showLoader() {
        var snapshot = self.presentationModel.value
        
        snapshot.removeAll(where: { $0 == .loading || $0 == .error })
        snapshot.append(.loading)
        
        self.presentationModel.value = snapshot
    }
    
    private func showError() {
        var snapshot = self.presentationModel.value
        
        snapshot.removeAll(where: { $0 == .loading || $0 == .error })
        snapshot.append(.error)
        
        self.presentationModel.value = snapshot
    }
    
    private func removeStatusViews() {
        var snapshot = self.presentationModel.value
        
        snapshot.removeAll(where: { $0 == .loading || $0 == .error })
        
        self.presentationModel.value = snapshot
    }
    
    private func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
}
