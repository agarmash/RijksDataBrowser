//
//  ErrorSectionHeaderView.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

class ErrorSectionHeaderView: UICollectionReusableView {
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Unable to load data\nTap to retry"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
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
        addSubview(errorLabel)

        NSLayoutConstraint.activate([
//            topAnchor.constraint(equalTo: errorLabel.topAnchor),
//            leadingAnchor.constraint(equalTo: errorLabel.leadingAnchor),
//            trailingAnchor.constraint(equalTo: errorLabel.trailingAnchor),
//            bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor)
            centerXAnchor.constraint(equalTo: errorLabel.centerXAnchor),
            centerYAnchor.constraint(equalTo: errorLabel.centerYAnchor),
            topAnchor.constraint(lessThanOrEqualTo: errorLabel.topAnchor),
            leadingAnchor.constraint(lessThanOrEqualTo: errorLabel.leadingAnchor)
        ])
    }
}
