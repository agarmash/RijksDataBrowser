//
//  ArtObjectsOverviewCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

class ArtObjectsOverviewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var viewModel: ArtObjectsOverviewCellViewModel!
    
    private var retainedBindings: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func fill(with viewModel: ArtObjectsOverviewCellViewModel) {
        self.viewModel = viewModel
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        titleLabel.text = viewModel.title
        
        let photoImageViewBinding = viewModel
            .$photo
            .receive(on: DispatchQueue.main)
            .sink { imageState in
                switch imageState {
                case .empty:
                    self.photoImageView.image = nil
                case .loading:
                    print("Loading")
                case .loaded(let image):
                    self.photoImageView.image = image
                case .errored:
                    print("error")
                }
            }
        
        retainedBindings.append(photoImageViewBinding)
    }
    
    override func prepareForReuse() {
        retainedBindings.removeAll()
        
        photoImageView.image = nil
    }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8.0),
            contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -8.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
            titleLabel.bottomAnchor.constraint(equalTo: photoImageView.topAnchor, constant: -8.0),
            contentView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: 0),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
            photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor),
            photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor, multiplier: 1)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
