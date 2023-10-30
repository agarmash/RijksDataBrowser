//
//  ArtObjectDetailsCoordinator.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

final class ArtObjectDetailsCoordinator: CoordinatorProtocol {
    
    // MARK: - Private Properties
    
    private let artObject: Collection.ArtObject
    private let presenter: UINavigationController
    private let dependencyContainer: DependencyContainerProtocol
    
    // MARK: - Init
    
    init(
        artObject: Collection.ArtObject,
        presenter: UINavigationController,
        dependencyContainer: DependencyContainerProtocol
    ) {
        self.artObject = artObject
        self.presenter = presenter
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Public Methods
    
    func start() {
        let viewModel = ArtObjectDetailsViewModel(
            artObject: artObject,
            imagesRepository: dependencyContainer.artObjectImagesRepository,
            collectionDetailsService: dependencyContainer.rijksCollectionDetailsService)
        
        let viewController = ArtObjectDetailsViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: true)
    }
}
