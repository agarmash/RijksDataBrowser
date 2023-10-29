//
//  ArtObjectsSectionHeaderView.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

class ArtObjectsSectionHeaderView: UICollectionReusableView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
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
    
    private var viewModel: ArtObjectsSectionHeaderViewModel!
    
    func fill(with viewModel: ArtObjectsSectionHeaderViewModel) {
        titleLabel.text = viewModel.title
    }
    
    func setupLayout() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0)
//            heightAnchor.constraint(equalToConstant: 24.0)
        ])
        
        backgroundColor = .lightGray
    }
}
