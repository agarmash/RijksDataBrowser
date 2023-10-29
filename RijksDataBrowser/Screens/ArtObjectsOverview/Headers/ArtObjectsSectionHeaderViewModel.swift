//
//  ArtObjectsSectionHeaderViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Foundation

class ArtObjectsSectionHeaderViewModel {
    private let pageNumber: Int
    
    init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
    
    var title: String {
        "Page \(pageNumber)"
    }
}
