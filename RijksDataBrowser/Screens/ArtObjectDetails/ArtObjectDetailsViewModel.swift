//
//  ArtObjectDetailsViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

final class ArtObjectDetailsViewModel {
    
    // MARK: - Types
    
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
    
    // MARK: - Public Properties
    
    @Published var state: State = .empty
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var imageState: ImageState = .empty
    
    let artObject: Collection.ArtObject
    
    // MARK: - Private Properties
    
    private var image: Image?
    
    private let imagesRepository: ArtObjectImagesRepositoryProtocol
    private let collectionDetailsService: RijksCollectionDetailsDataServiceProtocol
    
    // MARK: - Init
    
    init(
        artObject: Collection.ArtObject,
        imagesRepository: ArtObjectImagesRepositoryProtocol,
        collectionDetailsService: RijksCollectionDetailsDataServiceProtocol
    ) {
        self.artObject = artObject
        self.imagesRepository = imagesRepository
        self.collectionDetailsService = collectionDetailsService
    }
    
    // MARK: - Public Methods
    
    func loadDetails() {
        state = .loading
        Task {
            do {
                let collectionDetails = try await collectionDetailsService
                    .getCollectionDetails(for: artObject.objectNumber)
                
                preparePresentationData(from: collectionDetails.toDomain())
                state = .presentingContent
            } catch let error as URLError {
                state = .error("Network error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadImage() {
        guard let image = image else { return }
        
        imageState = .loading
        Task {
            do {
                let image = try await imagesRepository.getImage(for: image)
                imageState = .loaded(image)
            } catch ArtObjectImagesRepository.Error.missingImageURL {
                imageState = .error("Image URL is missing")
            } catch ArtObjectImagesRepository.Error.unableToPrepareThumbnail {
                imageState = .error("Unable to prepare a resized image")
            } catch ImageLoaderService.Error.incorrectDataReceived {
                imageState = .error("Incorrect image data received")
            } catch ImageLoaderService.Error.networkError(let error) {
                imageState = .error("Network error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func preparePresentationData(from collectionDetails: CollectionDetails) {
        title = collectionDetails.title
        description = collectionDetails.description
        image = collectionDetails.image
        
        loadImage()
    }
}
