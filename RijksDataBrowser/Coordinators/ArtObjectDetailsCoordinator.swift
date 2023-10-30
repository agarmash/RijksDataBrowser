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
    
    // MARK: - Init
    
    init(
        artObject: Collection.ArtObject,
        presenter: UINavigationController
    ) {
        self.artObject = artObject
        self.presenter = presenter
    }
    
    // MARK: - Public Methods
    
    func start() {
        let viewModel = ArtObjectDetailsViewModel(
            artObject: artObject,
            imagesRepository: ArtObjectImagesRepository(targetImageWidth: 400, imageLoader: ImageLoaderService()),
            collectionDetailsService: RijksDataService(client: NetworkClient()))
        
        let viewController = ArtObjectDetailsViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: true)
    }
}
