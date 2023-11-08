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

final class ImageProcessorService: ImageProcessorServiceProtocol {
    
    // MARK: - Types
    
    enum Error: Swift.Error {
        case imageDecodingFailed
    }
    
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
            throw Error.imageDecodingFailed
        }
        
        return preparedImage
    }
}
