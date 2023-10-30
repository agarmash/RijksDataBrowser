//
//  TestExtensions.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 30/10/2023.
//

import Foundation
@testable import RijksDataBrowser

extension Collection.ArtObject {
    static var dummy: Self {
        Collection.ArtObject(
            objectNumber: "SK-A-4118",
            title: "River Landscape with Riders",
            image: Image(
                url: URL(string: "https://aaa.bbb"),
                width: 2500,
                height: 1400))
    }
}

extension CollectionDetailsDTO {
    static var dummy: Self {
        CollectionDetailsDTO(
            artObject: CollectionDetailsDTO.ArtObjectDTO(
                title: "River Landscape with Riders",
                description: "Very detailed description",
                webImage: CollectionDetailsDTO.ArtObjectDTO.WebImageDTO(
                    url: "https://aaa.bbb",
                    width: 2500,
                    height: 1400)))
    }
}
