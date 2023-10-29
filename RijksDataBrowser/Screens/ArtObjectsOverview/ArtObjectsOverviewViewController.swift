//
//  ArtObjectsOverviewViewController.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

class ArtObjectsOverviewViewController: UIViewController {
    
    func makeDataSource(for collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Collection.ArtObject> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Collection.ArtObject>(
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
            
            let viewModel = viewModel.headerViewModel(for: indexPath)
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath) as! HeaderView
            
            headerView.fill(with: viewModel)
            
            return headerView
        }
        
        return dataSource
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Collection.ArtObject>?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerReusableCell(ofType: ArtObjectsOverviewCell.self)
        collectionView.registerReusableCell(ofType: LoadingCell.self)
        collectionView.registerReusableCell(ofType: ErrorCell.self)
        collectionView.registerReusableCell(ofType: EmptyCell.self)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.delegate = self
        return collectionView
    }()
    
    let viewModel: ArtObjectsOverviewViewModel!
    
    private var retainedBindings: [AnyCancellable] = []
    
    init(viewModel: ArtObjectsOverviewViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.viewModel = nil
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = collectionView
        dataSource = makeDataSource(for: collectionView)
        collectionView.dataSource = dataSource

        setupLayout()
        bindViewModel()
        
        viewModel.loadMore()
    }
    
    private func bindViewModel() {
        viewModel
            .$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [dataSource] snapshot in
                dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &retainedBindings)
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
//        collectionView.setNeedsLayout()
        
        cell.contentView.setNeedsLayout()
        if indexPath.row == 19 {
            viewModel.loadMore()
        }
    }
}

extension ArtObjectsOverviewViewController {
    
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
            widthDimension: .fractionalWidth(1.0),
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
