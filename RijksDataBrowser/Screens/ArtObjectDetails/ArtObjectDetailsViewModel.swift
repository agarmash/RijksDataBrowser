//
//  ArtObjectDetailsViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

class ArtObjectDetailsViewModel {
    
    enum State {
        case empty
        case loading
        case presentingContent
        case error(String)
    }
    
    enum ImageState {
        case empty
        case loading
        case loaded(UIImage)
        case error(String)
    }
    
    @Published var state: State = .empty
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var imageState: ImageState = .empty
    
    let artObject: Collection.ArtObject
//    var collectionDetails: CollectionDetails?
    
    var imageURL: URL?
    
    let imageLoaderService: ImageLoaderServiceProtocol
    let collectionDetailsService: RijksCollectionDetailsDataServiceProtocol
    
    init(
        artObject: Collection.ArtObject,
        imageLoaderService: ImageLoaderServiceProtocol,
        collectionDetailsService: RijksCollectionDetailsDataServiceProtocol
    ) {
        self.artObject = artObject
        self.imageLoaderService = imageLoaderService
        self.collectionDetailsService = collectionDetailsService
    }
    
    func loadDetails() {
        state = .loading
        Task {
            do {
                let collectionDetails = try await collectionDetailsService
                    .getCollectionDetails(for: artObject.objectNumber)
                self.preparePresentationData(from: collectionDetails.toDomain())
                state = .presentingContent
            } catch let error as URLError {
                state = .error("Network error: \(error.localizedDescription)")
            }
        }
    }
    
    func preparePresentationData(from collectionDetails: CollectionDetails) {
        title = collectionDetails.title
        description = collectionDetails.description
        imageURL = collectionDetails.imageURL
        
        loadImage()
    }
    
    func loadImage() {
        guard let url = imageURL else { return }
        
        imageState = .loading
        Task {
            do {
                let image = try await imageLoaderService.loadImage(with: url)
                self.imageState = .loaded(image)
            } catch let error as ImageLoaderService.Error {
                switch error {
                case .incorrectDataReceived:
                    imageState = .error("Invalid image data has been received")
                case .networkError(let error):
                    imageState = .error("Network error: \(error.localizedDescription)")
                }
            }
        }
    }
}
