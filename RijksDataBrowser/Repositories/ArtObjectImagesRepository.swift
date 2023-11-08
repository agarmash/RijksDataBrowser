//
//  ArtObjectImagesRepository.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

protocol ArtObjectImagesRepositoryProtocol {
    func getImage(for imageObject: Image) async throws -> UIImage
}

final class ArtObjectImagesRepository: ArtObjectImagesRepositoryProtocol {
    
    // MARK: - Types
    
    enum Error: Swift.Error {
        case missingImageURL
        case unableToPrepareThumbnail
    }
    
    // MARK: - Private Properties
    
    private let imageLoader: ImageLoaderServiceProtocol
    private let imageProcessor: ImageProcessorServiceProtocol
    
    // MARK: - Init
    
    init(
        imageLoader: ImageLoaderServiceProtocol,
        imageProcessor: ImageProcessorServiceProtocol
    ) {
        self.imageLoader = imageLoader
        self.imageProcessor = imageProcessor
    }
    
    // MARK: - Public Methods
    
    func getImage(for imageObject: Image) async throws -> UIImage {
        guard
            let imageURL = imageObject.url
        else {
            throw Error.missingImageURL
        }
        
        let image = try await imageLoader.loadImage(with: imageURL)
        
        let preparedImage = try await imageProcessor.prepareThumbnail(of: image)
        
        return preparedImage
    }
}
