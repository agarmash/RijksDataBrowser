//
//  CollectionDTO.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

struct CollectionDTO: Decodable {
    struct ArtObjectDTO: Decodable {
        struct WebImageDTO: Decodable {
            let url: String
        }
        
        let objectNumber: String
        let longTitle: String
        let webImage: WebImageDTO
    }
    
    let count: Int
    let artObjects: [ArtObjectDTO]
}

extension CollectionDTO.ArtObjectDTO {
    func toDomain() -> Collection.ArtObject {
        Collection.ArtObject(
            objectNumber: objectNumber,
            longTitle: longTitle,
            imageURL: URL(string: webImage.url))
    }
}

extension CollectionDTO {
    func toDomain() -> Collection {
        Collection(
            count: count,
            artObjects: artObjects.map { $0.toDomain() })
    }
}
