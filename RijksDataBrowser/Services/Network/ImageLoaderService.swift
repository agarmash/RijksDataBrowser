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
    func loadImage(with url: URL) async throws -> UIImage {
        do {
            let (imageData, _) = try await URLSession.shared.data(from: url)
            
            guard
                let image = await UIImage(data: imageData)?.byPreparingThumbnail(ofSize: CGSize(width: 400, height: 400))
//                let image = UIImage(data: imageData)
            else {
                throw Error.incorrectDataReceived
            }
            
            return image
        } catch let error as URLError {
            throw Error.networkError(error)
        }
    }
    
    enum Error: Swift.Error {
        case networkError(URLError)
        case incorrectDataReceived
    }
}
