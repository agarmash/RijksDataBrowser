//
//  Collection.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

struct Collection {
    struct ArtObject: Hashable {
        let objectNumber: String
        let title: String
        let image: Image
    }
    
    let count: Int
    let artObjects: [ArtObject]
}
