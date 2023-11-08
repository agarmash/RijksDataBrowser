//
//  DependencyContainer.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 30/10/2023.
//

import Foundation

protocol DependencyContainerProtocol {
    var rijksCollectionDataService: RijksCollectionDataServiceProtocol { get }
    var rijksCollectionDetailsService: RijksCollectionDetailsDataServiceProtocol { get }
    var artObjectsRepository: ArtObjectsRepositoryProtocol { get }
    var artObjectImagesRepository: ArtObjectImagesRepositoryProtocol { get }
}

final class DependencyContainer: DependencyContainerProtocol {
    
    // MARK: - Private Properties
    
    private let screenSize: CGSize
    
    private lazy var requestComposer = RequestComposer()
    private lazy var urlSession = URLSession.shared
    private lazy var responseParser = ResponseParser()
    
    private lazy var networkClient = NetworkClient(
        requestComposer: requestComposer,
        urlSession: urlSession,
        responseParser: responseParser)
    
    private lazy var rijksSecretsContainer = RijksSecretsContainer()
    private lazy var rijksDataService = RijksDataService(
        client: networkClient,
        secretsContainer: rijksSecretsContainer)
    
    private lazy var imageLoaderService = ImageLoaderService()
    private lazy var imageProcessorService = ImageProcessorService(screenSize: screenSize)
    
    // MARK: - Public Properties
    
    var rijksCollectionDataService: RijksCollectionDataServiceProtocol {
        rijksDataService
    }
    
    var rijksCollectionDetailsService: RijksCollectionDetailsDataServiceProtocol {
        rijksDataService
    }
    
    lazy var artObjectsRepository: ArtObjectsRepositoryProtocol = {
        ArtObjectsRepository(dataService: rijksCollectionDataService)
    }()
    
    lazy var artObjectImagesRepository: ArtObjectImagesRepositoryProtocol = {
        ArtObjectImagesRepository(
            imageLoader: imageLoaderService,
            imageProcessor: imageProcessorService)
    }()
    
    // MARK: - Init
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
    }
}
