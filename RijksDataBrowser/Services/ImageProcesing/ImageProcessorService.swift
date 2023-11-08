//
//  ImageProcessorService.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import UIKit

protocol ImageProcessorServiceProtocol {
    func prepareForDisplay(_ image: UIImage) async throws -> UIImage
}

final class ImageProcessorService: ImageProcessorServiceProtocol {
    enum Error: Swift.Error {
        case imageDecodingFailed
    }
    
    private let screenSize: CGSize
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
    }
    
    func prepareForDisplay(_ image: UIImage) async throws -> UIImage {
        guard
            let preparedImage = await image.byPreparingThumbnail(ofSize: screenSize)
        else {
            throw Error.imageDecodingFailed
        }
        
        return preparedImage
    }
}
