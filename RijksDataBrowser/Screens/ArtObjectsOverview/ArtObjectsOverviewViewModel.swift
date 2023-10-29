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
    
    @Published var snapshot: DiffableSnapshot = .init()
    
    enum SectionType: Hashable {
        case artObjectsPage(Int)
        case loading
        case error
    }
    
    enum Header {
        case artObjectsPage(ArtObjectsSectionHeaderViewModel)
        case loading
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
    
//    private func getArtsObject(for indexPath: IndexPath) -> Collection.ArtObject {
//        pagedArtObjects[indexPath.section][indexPath.row]
//    }
    
    func handleTap(on indexPath: IndexPath) {

    }
    
    func headerViewModel(for indexPath: IndexPath) -> ArtObjectsSectionHeaderViewModel {
        ArtObjectsSectionHeaderViewModel(pageNumber: indexPath.section + 1)
    }
    
    func loadMore() {
        showLoader()
        artObjectsRepository.loadMore { result in
            switch result {
            case .updatedObjects(let objects):
                self.pagedArtObjects = objects
                self.showLoadedObjects(objects)
            case .nothingMoreToLoad:
                self.hasMoreDataToLoad = false
            case .error:
                self.showError()
                self.didEncounterError = true
            }

            self.updateSubject.send()
        }
    }
    
    func showLoadedObjects(_ objects: [[Collection.ArtObject]]) {
        var snapshot = DiffableSnapshot()
        
        let sections = objects.indices.map { SectionType.artObjectsPage($0) }
//        let sections = objects.indices.map { _ in SectionType.artObjectsPage }
        
        snapshot.appendSections(sections)
        
        for (index, section) in sections.enumerated() {
            snapshot.appendItems(objects[index], toSection: section)
        }
        
        snapshot.appendSections([.loading, .error])
        
        self.snapshot = snapshot
    }
    
    func showLoader() {
        var snapshot = self.snapshot
        
        snapshot.deleteSections([.error, .loading])
        snapshot.appendSections([.loading])
        
        self.snapshot = snapshot
    }
    
    func showError() {
        var snapshot = self.snapshot
        
        snapshot.deleteSections([.error, .loading])
        snapshot.appendSections([.error])
        
        self.snapshot = snapshot
    }
    
    func preloadArtObject(for indexPath: IndexPath) {
        guard indexPath.section < pagedArtObjects.count else { return }

        let page = pagedArtObjects[indexPath.section]

        if page.count - indexPath.row < 2 {
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
            return .error
        }
    }
    
    private func clearError() {
        artObjectsRepository.clearError()
        didEncounterError = false
    }
    
    
}
