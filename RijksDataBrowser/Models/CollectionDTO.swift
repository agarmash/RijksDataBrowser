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
            let width: Int
            let height: Int
        }
        
        let objectNumber: String
        let title: String
        let webImage: WebImageDTO
    }
    
    let count: Int
    let artObjects: [ArtObjectDTO]
}

extension CollectionDTO.ArtObjectDTO.WebImageDTO {
    func toDomain() -> Collection.ArtObject.Image {
        Collection.ArtObject.Image(
            url: URL(string: url),
            width: width,
            height: height)
    }
}

extension CollectionDTO.ArtObjectDTO {
    func toDomain() -> Collection.ArtObject {
        Collection.ArtObject(
            objectNumber: objectNumber,
            title: title,
            image: webImage.toDomain())
    }
}

extension CollectionDTO {
    func toDomain() -> Collection {
        Collection(
            count: count,
            artObjects: artObjects.map { $0.toDomain() })
    }
}
