//
//  ArtObjectsOverviewViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import UIKit

typealias ArtObjectsOverviewDataSource = UICollectionViewDiffableDataSource<ArtObjectsOverviewSectionType, Collection.ArtObject>
typealias ArtObjectsOverviewSnapshot = NSDiffableDataSourceSnapshot<ArtObjectsOverviewSectionType, Collection.ArtObject>

enum ArtObjectsOverviewSectionType: Hashable {
    case artObjectsPage(Int)
    case loading
    case error
}

enum ArtObjectsOverviewHeaderType {
    case artObjectsPage(ArtObjectsSectionHeaderViewModelProtocol)
    case loading
    case error(ErrorSectionHeaderViewModelProtocol)
}

protocol ArtObjectsOverviewViewModelProtocol {
    typealias SectionType = ArtObjectsOverviewSectionType
    typealias HeaderType = ArtObjectsOverviewHeaderType
    
    typealias DiffableDataSource = ArtObjectsOverviewDataSource
    typealias DiffableSnapshot = ArtObjectsOverviewSnapshot
    
    var snapshot: CurrentValueSubject<DiffableSnapshot, Never> { get }
    
    func handleTap(on indexPath: IndexPath)
    func headerViewModel(for indexPath: IndexPath) -> ArtObjectsSectionHeaderViewModelProtocol
    func loadMore()
    func preloadArtObject(for indexPath: IndexPath)
    func header(for indexPath: IndexPath) -> HeaderType
    func makeOverviewCellViewModel(with artObject: Collection.ArtObject) -> ArtObjectsOverviewCellViewModelProtocol
}

final class ArtObjectsOverviewViewModel: ArtObjectsOverviewViewModelProtocol {
    
    // MARK: - Types
    
    enum Action {
        case showDetailsScreen(Collection.ArtObject)
    }

    // MARK: - Public Properties
    
    var snapshot = CurrentValueSubject<DiffableSnapshot, Never>(.init())
    
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
        switch snapshot.value.sectionIdentifiers[indexPath.section] {
        case .artObjectsPage:
            let artObject = pagedArtObjects[indexPath.section][indexPath.row]
            action(.showDetailsScreen(artObject))
        default:
            return
        }
    }
    
    func headerViewModel(for indexPath: IndexPath) -> ArtObjectsSectionHeaderViewModelProtocol {
        ArtObjectsSectionHeaderViewModel(pageNumber: indexPath.section + 1)
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
    
    func header(for indexPath: IndexPath) -> HeaderType {
        switch snapshot.value.sectionIdentifiers[indexPath.section] {
        case .artObjectsPage(let pageNumber):
            let viewModel = ArtObjectsSectionHeaderViewModel(pageNumber: pageNumber)
            return .artObjectsPage(viewModel)
        case .loading:
            return .loading
        case .error:
            let viewModel = ErrorSectionHeaderViewModel(didTapOnView: { [weak self] in
                self?.clearError()
                self?.loadMore()
            })
            return .error(viewModel)
        }
    }
    
    func makeOverviewCellViewModel(
        with artObject: Collection.ArtObject
    ) -> ArtObjectsOverviewCellViewModelProtocol {
        ArtObjectsOverviewCellViewModel(
            with: artObject,
            imageRepository: artObjectImagesRepository)
    }
    
    // MARK: - Private Methods
    
    private func showLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        var snapshot = DiffableSnapshot()
        
        let sections = objects.indices.map { SectionType.artObjectsPage($0) }
        
        snapshot.appendSections(sections)
        
        for (index, section) in sections.enumerated() {
            snapshot.appendItems(objects[index], toSection: section)
        }
        
        self.snapshot.value = snapshot
    }
    
    private func showLoader() {
        var snapshot = self.snapshot.value
        
        snapshot.deleteSections([.error, .loading])
        snapshot.appendSections([.loading])
        
        self.snapshot.value = snapshot
    }
    
    private func showError() {
        var snapshot = self.snapshot.value
        
        snapshot.deleteSections([.error, .loading])
        snapshot.appendSections([.error])
        
        self.snapshot.value = snapshot
    }
    
    private func removeStatusViews() {
        var snapshot = self.snapshot.value
        
        snapshot.deleteSections([.error, .loading])
        
        self.snapshot.value = snapshot
    }
    
    private func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
}
