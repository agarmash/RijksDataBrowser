//
//  ArtObjectsOverviewViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import UIKit

typealias DiffableDataSource = UICollectionViewDiffableDataSource<ArtObjectsOverviewViewModel.SectionType, Collection.ArtObject>
typealias DiffableSnapshot = NSDiffableDataSourceSnapshot<ArtObjectsOverviewViewModel.SectionType, Collection.ArtObject>

final class ArtObjectsOverviewViewModel {
    
    // MARK: - Types
    
    enum SectionType: Hashable {
        case artObjectsPage(Int)
        case loading
        case error
    }
    
    enum Header {
        case artObjectsPage(ArtObjectsSectionHeaderViewModel)
        case loading
        case error(ErrorSectionHeaderViewModel)
    }

    enum Action {
        case showDetailsScreen(Collection.ArtObject)
    }
    
    // MARK: - Public Properties
    
    @Published var snapshot: DiffableSnapshot = .init()
    
    let updateSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Private Properties
    
    private let action: (Action) -> Void
    
    private let artObjectsRepository: ArtObjectsRepositoryProtocol
    let artObjectImagesRepository: ArtObjectImagesRepositoryProtocol
    
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
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .artObjectsPage:
            let artObject = pagedArtObjects[indexPath.section][indexPath.row]
            action(.showDetailsScreen(artObject))
        default:
            return
        }
    }
    
    func headerViewModel(for indexPath: IndexPath) -> ArtObjectsSectionHeaderViewModel {
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

            self.updateSubject.send()
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
    
    func header(for indexPath: IndexPath) -> Header {
        switch snapshot.sectionIdentifiers[indexPath.section] {
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
    
    // MARK: - Private Methods
    
    private func showLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        var snapshot = DiffableSnapshot()
        
        let sections = objects.indices.map { SectionType.artObjectsPage($0) }
        
        snapshot.appendSections(sections)
        
        for (index, section) in sections.enumerated() {
            snapshot.appendItems(objects[index], toSection: section)
        }
        
        self.snapshot = snapshot
    }
    
    private func showLoader() {
        var snapshot = self.snapshot
        
        snapshot.deleteSections([.error, .loading])
        snapshot.appendSections([.loading])
        
        self.snapshot = snapshot
    }
    
    private func showError() {
        var snapshot = self.snapshot
        
        snapshot.deleteSections([.error, .loading])
        snapshot.appendSections([.error])
        
        self.snapshot = snapshot
    }
    
    private func removeStatusViews() {
        var snapshot = self.snapshot
        
        snapshot.deleteSections([.error, .loading])
        
        self.snapshot = snapshot
    }
    
    private func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
}
