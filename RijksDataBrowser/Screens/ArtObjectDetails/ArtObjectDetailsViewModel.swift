//
//  ArtObjectDetailsViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import UIKit

enum ArtObjectDetailsState: Equatable {
    case empty
    case loading
    case presentingContent
    case error(String)
}

enum ArtObjectDetailsImageState: Equatable {
    case empty
    case loading
    case loaded(UIImage)
    case error(String)
}

protocol ArtObjectDetailsViewModelProtocol {
    typealias State = ArtObjectDetailsState
    typealias ImageState = ArtObjectDetailsImageState
    
    var state: CurrentValueSubject<State, Never> { get }
    var title: CurrentValueSubject<String, Never> { get }
    var description: CurrentValueSubject<String, Never> { get }
    var imageState: CurrentValueSubject<ImageState, Never> { get }
    var artObject: Collection.ArtObject { get }
    
    func loadDetails()
    func loadImage()
}

final class ArtObjectDetailsViewModel: ArtObjectDetailsViewModelProtocol {
    
    // MARK: - Public Properties
    
    var state = CurrentValueSubject<State, Never>(.empty)
    
    var title = CurrentValueSubject<String, Never>("")
    var description = CurrentValueSubject<String, Never>("")
    var imageState = CurrentValueSubject<ImageState, Never>(.empty)
    
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
        state.value = .loading
        Task {
            do {
                let collectionDetails = try await collectionDetailsService
                    .getCollectionDetails(for: artObject.objectNumber)
                
                preparePresentationData(from: collectionDetails.toDomain())
                state.value = .presentingContent
            } catch RijksDataServiceError.networkClientError {
                state.value = .error("Unable to load the data")
            } catch {
                state.value = .error("Internal error")
            }
        }
    }
    
    func loadImage() {
        guard let image = image else { return }
        
        imageState.value = .loading
        Task {
            do {
                let image = try await imagesRepository.getImage(for: image)
                imageState.value = .loaded(image)
            } catch ArtObjectImagesRepositoryError.imageLoaderServiceError {
                imageState.value = .error("Unable to load the image")
            } catch {
                imageState.value = .error("Internal error")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func preparePresentationData(from collectionDetails: CollectionDetails) {
        title.value = collectionDetails.title
        description.value = collectionDetails.description
        image = collectionDetails.image
        
        loadImage()
    }
}
