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

enum ImageLoaderServiceError: Error {
    case networkError(URLError)
    case incorrectDataReceived
    case unknownError
}

final class ImageLoaderService: ImageLoaderServiceProtocol {
    
    // MARK: - Public Methods
    
    func loadImage(with url: URL) async throws -> UIImage {
        do {
            let (imageData, _) = try await URLSession.shared.data(from: url)
            
            guard
                let image = UIImage(data: imageData)
            else {
                throw ImageLoaderServiceError.incorrectDataReceived
            }
            
            return image
        } catch let error as URLError {
            throw ImageLoaderServiceError.networkError(error)
        } catch {
            throw ImageLoaderServiceError.unknownError
        }
    }
}
