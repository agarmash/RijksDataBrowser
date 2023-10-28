//
//  ArtObjectDetailsViewController.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

class ArtObjectDetailsViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: ArtObjectDetailsViewModel!

    init(viewModel: ArtObjectDetailsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.viewModel = nil
        
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(photoImageView)
        scrollView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8.0),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0),
            photoImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
            photoImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
            photoImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0),
            descriptionLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8.0),
            descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0),
            descriptionLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8.0)
        ])
    }

    private func bindViewModel() {
        
    }

}
