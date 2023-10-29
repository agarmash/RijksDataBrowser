//
//  ArtObjectDetailsCoordinator.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

class ArtObjectDetailsCoordinator: CoordinatorProtocol {
    
    let artObject: Collection.ArtObject
    let presenter: UINavigationController
    
    init(
        artObject: Collection.ArtObject,
        presenter: UINavigationController
    ) {
        self.artObject = artObject
        self.presenter = presenter
    }
    
    func start() {
        let viewModel = ArtObjectDetailsViewModel(
            artObject: artObject,
            imageLoaderService: ImageLoaderService(),
            collectionDetailsService: RijksDataService(client: NetworkClient()))
        
        let viewController = ArtObjectDetailsViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: true)
    }
}
