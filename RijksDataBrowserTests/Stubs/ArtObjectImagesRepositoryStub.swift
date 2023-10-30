//
//  ArtObjectImagesRepositoryStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

@testable import RijksDataBrowser
import UIKit

final class ArtObjectImagesRepositoryStub: ArtObjectImagesRepositoryProtocol {

    enum Mode {
        case returnValidData(UIImage)
        case throwError
    }
    
    enum MockError: Error {
        case simulatedError
    }
    
    var mode: Mode = .throwError
    
    func getImage(for imageObject: Image) async throws -> UIImage {
        switch mode {
        case .returnValidData(let image):
            return image
        case .throwError:
            throw MockError.simulatedError
        }
    }
}
