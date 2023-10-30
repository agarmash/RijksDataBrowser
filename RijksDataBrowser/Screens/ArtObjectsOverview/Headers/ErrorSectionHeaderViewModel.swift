//
//  ErrorSectionHeaderViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import Foundation

final class ErrorSectionHeaderViewModel {
    
    // MARK: - Public Properties
    
    let didTapOnView: (() -> Void)
    
    // MARK: - Init
    
    init(didTapOnView: @escaping () -> Void) {
        self.didTapOnView = didTapOnView
    }
}
