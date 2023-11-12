//
//  ArtObjectsOverviewCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import Combine
import UIKit

final class ArtObjectsOverviewCell: UICollectionViewCell {
    
    private enum Constants {
        static let insetSize: CGFloat = 8.0
    }
    
    // MARK: - Private Properties
    
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
            retryAction: { [viewModel] _ in viewModel?.loadPhoto() })
        
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
    
    private var viewModel: ArtObjectsOverviewCellViewModelProtocol?
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func fill(with viewModel: ArtObjectsOverviewCellViewModelProtocol) {
        self.viewModel = viewModel
        
        bindViewModel()
    }
    
    override func prepareForReuse() {
        cancellables.removeAll()
        
        photoImageView.image = nil
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        
        viewModel
            .photo
            .receive(on: DispatchQueue.main)
            .sink { [photoImageView, photoContainerView] imageState in
                switch imageState {
                case .loading:
                    photoContainerView.setState(.loading)
                case .loaded(let image):
                    photoImageView.image = image
                    photoContainerView.setState(.presentingContent)
                case .error(let errorMessage):
                    photoContainerView.setState(.error(errorMessage))
                default:
                    break
                }
            }
            .store(in: &cancellables)

        setPhotoImageViewAspectRatio(viewModel.photoAspectRatio)
    }
    
    private func setPhotoImageViewAspectRatio(_ ratio: CGFloat) {
        NSLayoutConstraint.deactivate([photoImageViewAspectRatioConstraint])

        let constraint = photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor, multiplier: ratio)
        constraint.priority = .defaultHigh

        NSLayoutConstraint.activate([constraint])
        photoImageViewAspectRatioConstraint = constraint
    }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(photoContainerView)
        
        photoImageViewAspectRatioConstraint = photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor)
        photoImageViewAspectRatioConstraint.priority = .defaultHigh
        
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
