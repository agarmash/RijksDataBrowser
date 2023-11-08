//
//  ErrorSectionHeaderViewModel.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import Foundation

protocol ErrorSectionHeaderViewModelProtocol {
    var message: String { get }
    var didTapOnView: (() -> Void) { get }
}

final class ErrorSectionHeaderViewModel: ErrorSectionHeaderViewModelProtocol {
    
    // MARK: - Public Properties
    
    // TODO: Replace with proper error description
    var message: String = "Unable to load data\nTap to retry"
    
    let didTapOnView: (() -> Void)
    
    // MARK: - Init
    
    init(didTapOnView: @escaping () -> Void) {
        self.didTapOnView = didTapOnView
    }
}
