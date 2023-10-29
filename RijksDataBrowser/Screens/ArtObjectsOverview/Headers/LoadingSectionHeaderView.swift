//
//  LoadingSectionHeaderView.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

class LoadingSectionHeaderView: UICollectionReusableView {
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        loadingIndicator.startAnimating()
    }
    
    func setupLayout() {
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor)
        ])
    }
}
