//
//  LoadingCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

class LoadingCell: UICollectionViewCell {
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
    
    func setupLayout() {
        contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }
}
