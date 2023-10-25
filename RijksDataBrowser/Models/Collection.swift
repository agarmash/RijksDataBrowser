//
//  Collection.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

struct Collection {
    struct ArtObject {
        let objectNumber: String
        let longTitle: String
        let imageURL: URL?
    }
    
    let count: Int
    let artObjects: [ArtObject]
}
