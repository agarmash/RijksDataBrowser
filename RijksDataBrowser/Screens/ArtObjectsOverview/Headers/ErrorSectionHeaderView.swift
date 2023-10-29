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
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapEvent))
        return recognizer
    }()
    
    @objc func handleTapEvent() {
        viewModel.didTapOnView?()
    }
    
    var viewModel: ErrorSectionHeaderViewModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func fill(with viewModel: ErrorSectionHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    func setupLayout() {
        addGestureRecognizer(tapGestureRecognizer)
        
        addSubview(errorLabel)

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: errorLabel.centerXAnchor),
            centerYAnchor.constraint(equalTo: errorLabel.centerYAnchor),
            topAnchor.constraint(lessThanOrEqualTo: errorLabel.topAnchor),
            leadingAnchor.constraint(lessThanOrEqualTo: errorLabel.leadingAnchor)
        ])
    }
}
