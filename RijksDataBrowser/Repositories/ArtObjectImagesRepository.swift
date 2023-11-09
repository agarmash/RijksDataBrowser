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

enum ArtObjectImagesRepositoryError: Error {
    case missingImageURL
    case unableToPrepareThumbnail
    case imageLoaderServiceError(ImageLoaderServiceError)
    case imageProcessorServiceError(ImageProcessorServiceError)
    case unknownError
}

final class ArtObjectImagesRepository: ArtObjectImagesRepositoryProtocol {
    
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
            throw ArtObjectImagesRepositoryError.missingImageURL
        }
        
        do {
            let image = try await imageLoader.loadImage(with: imageURL)
            return try await imageProcessor.prepareThumbnail(of: image)
        } catch let error as ImageLoaderServiceError {
            throw ArtObjectImagesRepositoryError.imageLoaderServiceError(error)
        } catch let error as ImageProcessorServiceError {
            throw ArtObjectImagesRepositoryError.imageProcessorServiceError(error)
        } catch {
            throw ArtObjectImagesRepositoryError.unknownError
        }
    }
}
