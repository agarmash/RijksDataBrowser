//
//  ArtObjectsOverviewCellViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

final class ArtObjectsOverviewCellViewModel {
    
    enum ImageState {
        case empty
        case loading
        case loaded(UIImage)
        case error(String)
    }
    
    private let artObject: Collection.ArtObject
    private let imageRepository: ArtObjectImagesRepositoryProtocol
    
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
    
    var title: String {
        artObject.title
    }
    
    var photoAspectRatio: CGFloat {
        CGFloat(artObject.image.width) / CGFloat(artObject.image.height)
    }
    
    @Published var photo: ImageState = .empty
    
    func loadPhoto() {
        Task {
            do {
                photo = .loading
                let image = try await imageRepository.getImage(for: artObject.image)
                photo = .loaded(image)
            } catch ArtObjectImagesRepository.Error.missingImageURL {
                photo = .error("Image URL is missing")
            } catch ArtObjectImagesRepository.Error.unableToPrepareThumbnail {
                photo = .error("Unable to prepare a resized image")
            } catch ImageLoaderService.Error.incorrectDataReceived {
                photo = .error("Incorrect image data received")
            } catch ImageLoaderService.Error.networkError(let error) {
                photo = .error("Network error: \(error.localizedDescription)")
            }
        }
    }
}
