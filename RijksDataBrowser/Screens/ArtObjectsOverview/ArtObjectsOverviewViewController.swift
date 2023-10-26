//
//  ArtObjectsOverviewViewController.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

class ArtObjectsOverviewViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = ArtObjectsFlowLayout()
//        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        flowLayout.estimatedItemSize = CGSize(width: self.view.frame.size.width, height: 30)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 30)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerReusableCell(ofType: ArtObjectsOverviewCell.self)
        collectionView.registerReusableCell(ofType: LoadingCell.self)
        collectionView.registerReusableCell(ofType: EmptyCell.self)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .always
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

        setupLayout()
        bindViewModel()
        
//        viewModel.
    }
    
    private func bindViewModel() {
        let updateBinding = viewModel
            .updateSubject
            .receive(on: DispatchQueue.main)
            .sink { [collectionView] in
//                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
                collectionView.reloadData()
            }
        
        retainedBindings.append(updateBinding)
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

extension ArtObjectsOverviewViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let aaa = viewModel.numberOfSections()
        print("#### Number of sections: \(aaa)")
        return aaa
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let aaa = viewModel.numberOfRowsInSection(index: section)
        print("#### Number of items in section \(section): \(aaa)")
        return aaa
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = viewModel.cell(for: indexPath)
        
        print("#### Cell for section \(indexPath.section) row \(indexPath.row): \(cell)")
        
        collectionView.setNeedsLayout()
        
        switch cell {
        case .empty, .error:
            let cell = collectionView.dequeueReusableCell(ofType: EmptyCell.self, for: indexPath)
            return cell
        case .loading:
            let cell = collectionView.dequeueReusableCell(ofType: LoadingCell.self, for: indexPath)
            return cell
        case .artObject(let viewModel):
            let cell = collectionView.dequeueReusableCell(ofType: ArtObjectsOverviewCell.self, for: indexPath)
            cell.fill(with: viewModel)
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let viewModel = viewModel.headerViewModel(for: indexPath)
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderView",
            for: indexPath) as! HeaderView
        
        headerView.fill(with: viewModel)
        
        return headerView
    }
}

//extension ArtObjectsOverviewViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
////        let cellWidth = collectionView.frame.width / CGFloat(numberOfColumns)
////        return FavouriteCollectionViewCell.size(for: cellWidth)
//        let cell = viewModel.cell(for: indexPath)
//
//        switch cell {
//        case .empty, .loading, .error:
//            return CGSize(width: collectionView.frame.width, height: 40.0)
//        case .artObject(let viewModel):
//            return viewModel.size(for: collectionView.frame.width)
//        }
//    }
//}

extension ArtObjectsOverviewViewController: UICollectionViewDelegate {
    
}
