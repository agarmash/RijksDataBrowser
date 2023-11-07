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
    var imageLoaderService: ImageLoaderServiceProtocol { get }
    var artObjectsRepository: ArtObjectsRepositoryProtocol { get }
    var artObjectImagesRepository: ArtObjectImagesRepositoryProtocol { get }
}

final class DependencyContainer: DependencyContainerProtocol {
    
    private lazy var requestComposer = RequestComposer()
    private lazy var urlSession = URLSession.shared
    private lazy var responseParser = ResponseParser()
    
    private lazy var networkClient = NetworkClient(
        requestComposer: requestComposer,
        urlSession: urlSession,
        responseParser: responseParser)
    
    private lazy var rijksDataService = RijksDataService(client: networkClient)
    
    private let targetImageWidth: Int
    
    init(targetImageWidth: Int) {
        self.targetImageWidth = targetImageWidth
    }
    
    var rijksCollectionDataService: RijksCollectionDataServiceProtocol {
        rijksDataService
    }
    
    var rijksCollectionDetailsService: RijksCollectionDetailsDataServiceProtocol {
        rijksDataService
    }
    
    lazy var imageLoaderService: ImageLoaderServiceProtocol = {
        ImageLoaderService()
    }()
    
    lazy var artObjectsRepository: ArtObjectsRepositoryProtocol = {
        ArtObjectsRepository(dataService: rijksCollectionDataService)
    }()
    
    lazy var artObjectImagesRepository: ArtObjectImagesRepositoryProtocol = {
        ArtObjectImagesRepository(targetImageWidth: targetImageWidth, imageLoader: imageLoaderService)
    }()
}
