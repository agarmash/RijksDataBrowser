//
//  Image.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import Foundation

struct Image: Hashable {
    let url: URL?
    let width: Int
    let height: Int
}

extension Image {
    var aspectRatio: Double {
        Double(width) / Double(height)
    }
}
