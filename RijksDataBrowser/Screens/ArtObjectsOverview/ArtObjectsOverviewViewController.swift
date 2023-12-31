//
//  ArtObjectsOverviewViewController.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

final class ArtObjectsOverviewViewController: UIViewController {
    
    // MARK: - Types
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<ArtObjectsOverviewSectionType, Collection.ArtObject>
    typealias DiffableSnapshot = NSDiffableDataSourceSnapshot<ArtObjectsOverviewSectionType, Collection.ArtObject>
    
    // MARK: - Private Properties
    
    private var dataSource: DiffableDataSource?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerReusableCell(ofType: ArtObjectsOverviewCell.self)
        collectionView.registerSupplementaryView(ofType: ArtObjectsSectionHeaderView.self, kind: .header)
        collectionView.registerSupplementaryView(ofType: LoadingSectionHeaderView.self, kind: .header)
        collectionView.registerSupplementaryView(ofType: ErrorSectionHeaderView.self, kind: .header)
        collectionView.delegate = self
        return collectionView
    }()
    
    private let viewModel: ArtObjectsOverviewViewModelProtocol
    private let mapper: ArtObjectsOverviewViewModelMapperProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        viewModel: ArtObjectsOverviewViewModelProtocol,
        mapper: ArtObjectsOverviewViewModelMapperProtocol
    ) {
        self.viewModel = viewModel
        self.mapper = mapper
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = collectionView
        dataSource = makeDataSource(for: collectionView)
        collectionView.dataSource = dataSource

        setupLayout()
        bindViewModel()
        
        viewModel.loadMore()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel
            .presentationModel
            .receive(on: DispatchQueue.main)
            .sink { [dataSource] model in
                var snapshot = DiffableSnapshot()
        
                snapshot.appendSections(model)
        
                for section in model {
                    switch section {
                    case let .artObjectsPage(pageNumber: _, objects: objects):
                        snapshot.appendItems(objects, toSection: section)
                    default:
                        break
                    }
                }
                
                dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionView.topAnchor),
            view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ArtObjectsOverviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        viewModel.handleTap(on: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        viewModel.preloadArtObject(for: indexPath)
    }
}

private extension ArtObjectsOverviewViewController {
    private func makeDataSource(for collectionView: UICollectionView) -> DiffableDataSource {
        let dataSource = DiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [mapper] collectionView, indexPath, artObject in
                let cell = collectionView.dequeueReusableCell(ofType: ArtObjectsOverviewCell.self, for: indexPath)
                let viewModel = mapper.makeArtObjectCellViewModel(with: artObject)
                cell.fill(with: viewModel)
                return cell
            })
        
        dataSource.supplementaryViewProvider = { [mapper, viewModel] collectionView, kind, indexPath in
            guard
                let dataSource = collectionView.dataSource as? DiffableDataSource
            else {
                return nil
            }

            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case let .artObjectsPage(pageNumber: pageNumber, objects: _):
                let headerView = collectionView.dequeueSupplementaryView(
                    ofType: ArtObjectsSectionHeaderView.self,
                    kind: .header,
                    for: indexPath)
                
                let viewModel = mapper.makePageHeaderViewModel(pageNumber: pageNumber)
                headerView.fill(with: viewModel)
    
                return headerView
            case .loading:
                let headerView = collectionView.dequeueSupplementaryView(
                    ofType: LoadingSectionHeaderView.self,
                    kind: .header,
                    for: indexPath)
    
                return headerView
            case .error:
                let headerView = collectionView.dequeueSupplementaryView(
                    ofType: ErrorSectionHeaderView.self,
                    kind: .header,
                    for: indexPath)
    
                let viewModel = mapper.makeErrorHeaderViewModel(didTapOnView: { [viewModel] in
                    viewModel.loadMore()
                })
                headerView.fill(with: viewModel)
                
                return headerView
            }
        }
        
        return dataSource
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(30)
        )

        let item = NSCollectionLayoutItem(layoutSize: size)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: size,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(50)
        )

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
