//
//  ArtObjectsSectionHeaderViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Foundation

final class ArtObjectsSectionHeaderViewModel {
    
    // MARK: - Public Properties
    
    var title: String {
        "Page \(pageNumber)"
    }
    
    // MARK: - Private Properties
    
    private let pageNumber: Int
    
    // MARK: - Init
    
    init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
}
