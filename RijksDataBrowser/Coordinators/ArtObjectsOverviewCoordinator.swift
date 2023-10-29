//
//  ArtObjectsOverviewCoordinator.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

class ArtObjectsOverviewCoordinator: CoordinatorProtocol {

    // MARK: - Private Properties

    private let window: UIWindow
    private let presenter = UINavigationController()

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public Methods

    func start() {
//        let presenter = UINavigationController()
        window.rootViewController = presenter
        
        let artObjectsRepository = ArtObjectsRepository(
            dataService: RijksDataService(
                client: NetworkClient()))
        
        let artObjectImagesRepository = ArtObjectImagesRepository(
            targetImageWidth: Int(window.frame.width),
            imageLoader: ImageLoaderService())
        
        let viewModel = ArtObjectsOverviewViewModel(
            action: { action in
                switch action {
                case .showDetailsScreen(let artObject):
                    self.showDetailsScreen(artObject: artObject)
                }
            },
            artObjectsRepository: artObjectsRepository,
            artObjectImagesRepository: artObjectImagesRepository)
        
        let viewController = ArtObjectsOverviewViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: false)
        window.makeKeyAndVisible()
    }
    
    func showDetailsScreen(artObject: Collection.ArtObject) {
        let detailsCoordinator = ArtObjectDetailsCoordinator(
            artObject: artObject,
            presenter: presenter)
        
        detailsCoordinator.start()
    }
}
