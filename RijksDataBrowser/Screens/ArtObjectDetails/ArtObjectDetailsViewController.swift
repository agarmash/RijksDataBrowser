//
//  ArtObjectDetailsViewController.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import Combine
import UIKit

class ArtObjectDetailsViewController: UIViewController {
    
    private lazy var containerView: LoadableErrorableView = {
        let view = LoadableErrorableView(
            contentView: scrollView,
            retryAction: { _ in self.viewModel.loadDetails() })
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private lazy var photoContainerView: LoadableErrorableView = {
        let view = LoadableErrorableView(
            contentView: photoImageView,
            retryAction: { _ in self.viewModel.loadImage() })
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        bindViewModel()
        viewModel.loadDetails()
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(photoContainerView)
        scrollView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8.0),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0),
            photoContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
            photoContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
            photoContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0),
            descriptionLabel.topAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: 8.0),
            descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0),
            descriptionLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8.0)
        ])
        
        view.backgroundColor = .systemBackground
    }
    
    var cancellables = Set<AnyCancellable>()

    private func bindViewModel() {
        viewModel
            .$state
            .receive(on: DispatchQueue.main)
            .sink { [containerView] state in
                switch state {
                case .loading:
                    containerView.setState(.loading)
                case .presentingContent:
                    containerView.setState(.presentingContent)
                case .error(let errorMessage):
                    containerView.setState(.error(errorMessage))
                default:
                    return
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .$title
            .receive(on: DispatchQueue.main)
            .sink { [titleLabel] title in
                titleLabel.text = title
            }
            .store(in: &cancellables)
        
        viewModel
            .$description
            .receive(on: DispatchQueue.main)
            .sink { [descriptionLabel] description in
                descriptionLabel.text = description
            }
            .store(in: &cancellables)
        
        viewModel
            .$imageState
            .receive(on: DispatchQueue.main)
            .sink { [photoImageView, photoContainerView] imageState in
                switch imageState {
                case .loading:
                    photoContainerView.setState(.loading)
                case .loaded(let image):
                    photoContainerView.setState(.presentingContent)
                    photoImageView.image = image
                case .error(let errorMessage):
                    photoContainerView.setState(.error(errorMessage))
                default:
                    return
                }
            }
            .store(in: &cancellables)
    }

}
