//
//  ArtObjectsOverviewCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

class ArtObjectsOverviewCell: UICollectionViewCell {
    
    private enum Constants {
        static let insetSize: CGFloat = 8.0
        static let labelHeight: CGFloat = 20.0
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var photoContainerView: LoadableErrorableView = {
        let view = LoadableErrorableView(
            contentView: photoImageView,
            retryAction: { _ in self.viewModel.loadPhoto() })
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    private var photoImageViewAspectRatioConstraint: NSLayoutConstraint!
    
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
                case .loading:
                    self.photoContainerView.setState(.loading)
                case .loaded(let image):
                    self.photoImageView.image = image
                    self.photoContainerView.setState(.presentingContent)
                case .error(let errorMessage):
                    self.photoContainerView.setState(.error(errorMessage))
                default:
                    break
                }
                
                self.contentView.layoutSubviews()
            }
        
        retainedBindings.append(photoImageViewBinding)
        
        setPhotoImageViewAspectRatio(viewModel.photoAspectRatio)
    }
    
    func setPhotoImageViewAspectRatio(_ ratio: CGFloat) {
        NSLayoutConstraint.deactivate([photoImageViewAspectRatioConstraint])

        let constraint = photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor, multiplier: ratio)

        NSLayoutConstraint.activate([constraint])
        photoImageViewAspectRatioConstraint = constraint
        
        contentView.layoutSubviews()
    }
    
    override func prepareForReuse() {
        retainedBindings.removeAll()
        
        photoImageView.image = nil
    }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(photoContainerView)
        
        photoImageViewAspectRatioConstraint = photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -Constants.insetSize),
            contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -Constants.insetSize),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.insetSize),
            titleLabel.bottomAnchor.constraint(equalTo: photoContainerView.topAnchor, constant: -Constants.insetSize),
            contentView.leadingAnchor.constraint(equalTo: photoContainerView.leadingAnchor),
            photoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.insetSize),
            photoImageViewAspectRatioConstraint
        ])
    }
}
