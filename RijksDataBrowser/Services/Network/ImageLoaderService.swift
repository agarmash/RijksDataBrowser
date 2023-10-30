//
//  ImageLoaderService.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import UIKit

protocol ImageLoaderServiceProtocol {
    func loadImage(with url: URL) async throws -> UIImage
}

final class ImageLoaderService: ImageLoaderServiceProtocol {
    // MARK: - Types
    
    enum Error: Swift.Error {
        case networkError(URLError)
        case incorrectDataReceived
    }
    
    // MARK: - Public Methods
    
    func loadImage(with url: URL) async throws -> UIImage {
        do {
            let (imageData, _) = try await URLSession.shared.data(from: url)
            
            guard
                let image = UIImage(data: imageData)
            else {
                throw Error.incorrectDataReceived
            }
            
            return image
        } catch let error as URLError {
            throw Error.networkError(error)
        }
    }
}
