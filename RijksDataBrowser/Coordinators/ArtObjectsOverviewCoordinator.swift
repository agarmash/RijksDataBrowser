//
//  ArtObjectsOverviewCoordinator.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

final class ArtObjectsOverviewCoordinator: CoordinatorProtocol {

    // MARK: - Private Properties

    private let window: UIWindow
    private let presenter = UINavigationController()
    
    private lazy var dataService = RijksDataService(client: NetworkClient())
    private lazy var imagesRepository = ArtObjectImagesRepository(
        targetImageWidth: Int(window.frame.width),
        imageLoader: ImageLoaderService())

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public Methods

    func start() {
        window.rootViewController = presenter
        
        let artObjectsRepository = ArtObjectsRepository(dataService: dataService)
        
        let viewModel = ArtObjectsOverviewViewModel(
            action: { [weak self] action in
                switch action {
                case .showDetailsScreen(let artObject):
                    self?.showDetailsScreen(artObject: artObject)
                }
            },
            artObjectsRepository: artObjectsRepository,
            artObjectImagesRepository: imagesRepository)
        
        let viewController = ArtObjectsOverviewViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: false)
        window.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    
    private func showDetailsScreen(artObject: Collection.ArtObject) {
        let detailsCoordinator = ArtObjectDetailsCoordinator(
            artObject: artObject,
            presenter: presenter,
            imagesRepository: imagesRepository,
            collectionDetailsService: dataService)
        
        detailsCoordinator.start()
    }
}
