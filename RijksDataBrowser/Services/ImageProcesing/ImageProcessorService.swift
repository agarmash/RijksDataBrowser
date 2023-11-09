//
//  ImageProcessorService.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import UIKit

protocol ImageProcessorServiceProtocol {
    func prepareThumbnail(of image: UIImage) async throws -> UIImage
}

enum ImageProcessorServiceError: Error {
    case imageDecodingFailed
}

final class ImageProcessorService: ImageProcessorServiceProtocol {
    
    // MARK: - Private Properties
    
    private let screenSize: CGSize
    
    // MARK: - Init
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
    }
    
    // MARK: - Public Methods
    
    func prepareThumbnail(of image: UIImage) async throws -> UIImage {
        guard
            let preparedImage = await image.byPreparingThumbnail(ofSize: screenSize)
        else {
            throw ImageProcessorServiceError.imageDecodingFailed
        }
        
        return preparedImage
    }
}
