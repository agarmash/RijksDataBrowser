//
//  LoadingSectionHeaderView.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

final class LoadingSectionHeaderView: UICollectionReusableView {
    
    // MARK: - Private Properties
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        loadingIndicator.startAnimating()
    }
    
    // MARK: - Private Methods
    
    private func setupLayout() {
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor)
        ])
    }
}
