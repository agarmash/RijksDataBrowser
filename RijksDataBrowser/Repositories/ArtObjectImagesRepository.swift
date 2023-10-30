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
    private let targetImageWidth: Int
    
    // MARK: - Init
    
    init(
        targetImageWidth: Int,
        imageLoader: ImageLoaderServiceProtocol
    ) {
        self.targetImageWidth = targetImageWidth
        self.imageLoader = imageLoader
    }
    
    // MARK: - Public Methods
    
    func getImage(for imageObject: Image) async throws -> UIImage {
        guard
            let imageURL = imageObject.url
        else {
            throw Error.missingImageURL
        }
        
        let image = try await imageLoader.loadImage(with: imageURL)
        
        let newImageSize = getSizeForResizing(imageObject)
        
        guard
            let resizedImage = await image.byPreparingThumbnail(ofSize: newImageSize)
        else {
            throw Error.unableToPrepareThumbnail
        }

        return resizedImage
    }
    
    // MARK: - Private Methods
    
    private func getSizeForResizing(_ imageObject: Image) -> CGSize {
        let imageWidth = Double(min(targetImageWidth, imageObject.width))
        let imageHeight = imageWidth / imageObject.aspectRatio
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
}
