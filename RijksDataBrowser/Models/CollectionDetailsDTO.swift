//
//  CollectionDetailsDTO.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import Foundation

struct CollectionDetailsDTO: Decodable {
    struct ArtObjectDTO: Decodable {
        struct WebImageDTO: Decodable {
            let url: String
            let width: Int
            let height: Int
        }
        
        let title: String
        let description: String
        let webImage: WebImageDTO
    }
    
    let artObject: ArtObjectDTO
}

extension CollectionDetailsDTO.ArtObjectDTO.WebImageDTO {
    func toDomain() -> Image {
        Image(
            url: URL(string: url),
            width: width,
            height: height)
    }
}

extension CollectionDetailsDTO {
    func toDomain() -> CollectionDetails {
        CollectionDetails(
            title: artObject.title,
            description: artObject.description,
            image: artObject.webImage.toDomain())
    }
}
