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
    
    private let imagesRepository: ArtObjectImagesRepositoryProtocol
    private let collectionDetailsService: RijksCollectionDetailsDataServiceProtocol
    
    // MARK: - Init
    
    init(
        artObject: Collection.ArtObject,
        presenter: UINavigationController,
        imagesRepository: ArtObjectImagesRepositoryProtocol,
        collectionDetailsService: RijksCollectionDetailsDataServiceProtocol
    ) {
        self.artObject = artObject
        self.presenter = presenter
        self.imagesRepository = imagesRepository
        self.collectionDetailsService = collectionDetailsService
    }
    
    // MARK: - Public Methods
    
    func start() {
        let viewModel = ArtObjectDetailsViewModel(
            artObject: artObject,
            imagesRepository: imagesRepository,
            collectionDetailsService: collectionDetailsService)
        
        let viewController = ArtObjectDetailsViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: true)
    }
}
