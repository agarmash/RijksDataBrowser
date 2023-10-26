//
//  ErrorCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

class ErrorCell: UICollectionViewCell {
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
        contentView.addSubview(errorLabel)

        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: errorLabel.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: errorLabel.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: errorLabel.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor)
            contentView.centerXAnchor.constraint(equalTo: errorLabel.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: errorLabel.centerYAnchor),
            contentView.topAnchor.constraint(lessThanOrEqualTo: errorLabel.topAnchor),
            contentView.leadingAnchor.constraint(lessThanOrEqualTo: errorLabel.leadingAnchor)
        ])
    }
}
