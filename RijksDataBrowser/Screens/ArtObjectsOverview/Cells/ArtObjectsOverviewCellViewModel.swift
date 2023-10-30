//
//  ArtObjectsOverviewCellViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

protocol ArtObjectsOverviewCellViewModelProtocol {
    typealias ImageState = ArtObjectsOverviewCellImageState
    
    var title: String { get }
    var photoAspectRatio: CGFloat { get }
    var photo: CurrentValueSubject<ImageState, Never> { get }
    
    func loadPhoto()
}

enum ArtObjectsOverviewCellImageState {
    case empty
    case loading
    case loaded(UIImage)
    case error(String)
}

final class ArtObjectsOverviewCellViewModel: ArtObjectsOverviewCellViewModelProtocol {
    
    // MARK: - Public Properties
    
    var title: String {
        artObject.title
    }
    
    var photoAspectRatio: CGFloat {
        artObject.image.aspectRatio
    }
    
    var photo = CurrentValueSubject<ImageState, Never>(.empty)
    
    // MARK: - Private Properties
    
    private let artObject: Collection.ArtObject
    private let imageRepository: ArtObjectImagesRepositoryProtocol
    
    // MARK: - Init
    
    init(
        with artObject: Collection.ArtObject,
        imageRepository: ArtObjectImagesRepositoryProtocol
    ) {
        self.artObject = artObject
        self.imageRepository = imageRepository
        
        if artObject.image.url != nil {
            loadPhoto()
        }
    }
    
    // MARK: - Public Methods
    
    func loadPhoto() {
        Task {
            do {
                photo.value = .loading
                let image = try await imageRepository.getImage(for: artObject.image)
                photo.value = .loaded(image)
            } catch ArtObjectImagesRepository.Error.missingImageURL {
                photo.value = .error("Image URL is missing")
            } catch ArtObjectImagesRepository.Error.unableToPrepareThumbnail {
                photo.value = .error("Unable to prepare a resized image")
            } catch ImageLoaderService.Error.incorrectDataReceived {
                photo.value = .error("Incorrect image data received")
            } catch ImageLoaderService.Error.networkError(let error) {
                photo.value = .error("Network error: \(error.localizedDescription)")
            } catch {
                photo.value = .error("Unknown error")
            }
        }
    }
}
