//
//  ArtObjectsOverviewCoordinator.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

final class ArtObjectsOverviewCoordinator: CoordinatorProtocol {

    // MARK: - Private Properties
    
    private let presenter: UINavigationController
    private let dependencyContainer: DependencyContainerProtocol

    // MARK: - Init

    init(
        presenter: UINavigationController,
        dependencyContainer: DependencyContainerProtocol
    ) {
        self.presenter = presenter
        self.dependencyContainer = dependencyContainer
    }

    // MARK: - Public Methods

    func start() {     
        let viewModel = ArtObjectsOverviewViewModel(
            action: { [weak self] action in
                switch action {
                case .showDetailsScreen(let artObject):
                    self?.showDetailsScreen(artObject: artObject)
                }
            },
            artObjectsRepository: dependencyContainer.artObjectsRepository,
            artObjectImagesRepository: dependencyContainer.artObjectImagesRepository)
        
        let viewController = ArtObjectsOverviewViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: false)
    }
    
    // MARK: - Private Methods
    
    private func showDetailsScreen(artObject: Collection.ArtObject) {
        let detailsCoordinator = ArtObjectDetailsCoordinator(
            artObject: artObject,
            presenter: presenter,
            dependencyContainer: dependencyContainer)
        
        detailsCoordinator.start()
    }
}
