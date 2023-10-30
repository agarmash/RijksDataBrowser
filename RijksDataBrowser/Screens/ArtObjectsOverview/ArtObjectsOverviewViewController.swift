//
//  ArtObjectsOverviewViewController.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

final class ArtObjectsOverviewViewController: UIViewController {
    
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
    
    private let viewModel: ArtObjectsOverviewViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: ArtObjectsOverviewViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.viewModel = nil
        
        super.init(coder: coder)
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
            .$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [dataSource] snapshot in
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
            cellProvider: { collectionView, indexPath, artObject in
                let cell = collectionView.dequeueReusableCell(ofType: ArtObjectsOverviewCell.self, for: indexPath)
                let viewModel = ArtObjectsOverviewCellViewModel(with: artObject, imageRepository: self.viewModel.artObjectImagesRepository)
                cell.fill(with: viewModel)
                return cell
            }
        )
        
        dataSource.supplementaryViewProvider = { [unowned self]
            (collectionView, kind, indexPath) -> UICollectionReusableView? in

            switch viewModel.header(for: indexPath) {
            case .artObjectsPage(let viewModel):
                let headerView = collectionView.dequeueSupplementaryView(
                    ofType: ArtObjectsSectionHeaderView.self,
                    kind: .header,
                    for: indexPath)
    
                headerView.fill(with: viewModel)
    
                return headerView
            case .loading:
                let headerView = collectionView.dequeueSupplementaryView(
                    ofType: LoadingSectionHeaderView.self,
                    kind: .header,
                    for: indexPath)
    
                return headerView
            case .error(let viewModel):
                let headerView = collectionView.dequeueSupplementaryView(
                    ofType: ErrorSectionHeaderView.self,
                    kind: .header,
                    for: indexPath)
    
                headerView.fill(with: viewModel)
                
                return headerView
            }
        }
        
        return dataSource
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(300)
        ))

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(300)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
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
