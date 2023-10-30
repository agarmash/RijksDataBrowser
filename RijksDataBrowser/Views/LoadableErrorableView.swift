//
//  LoadableErrorableView.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

final class LoadableErrorableView: UIView {
    
    // MARK: - Types
    
    enum State {
        case empty
        case loading
        case presentingContent
        case error(String)
    }
    
    // MARK: - Private Properties
    
    private let contentView: UIView
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    private let retryAction: (LoadableErrorableView) -> Void

    // MARK: - Init
    
    init(
        contentView: UIView,
        retryAction: @escaping (LoadableErrorableView) -> Void,
        retryButtonTitle: String = "Retry"
    ) {
        self.contentView = contentView
        self.retryAction = retryAction
        
        super.init(frame: .zero)
        
        self.retryButton.setTitle(retryButtonTitle, for: .normal)
        setupLayout()
        
        setState(.empty)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.contentView = UIView()
        self.retryAction = { _ in }
        super.init(coder: coder)
    }
    
    // MARK: - Public Methods
    
    func setState(_ state: State) {
        switch state {
        case .empty:
            contentView.isHidden = true
            loadingIndicator.isHidden = true
            errorView.isHidden = true
        case .loading:
            contentView.isHidden = true
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            errorView.isHidden = true
        case .presentingContent:
            contentView.isHidden = false
            loadingIndicator.isHidden = true
            errorView.isHidden = true
        case .error(let errorMessage):
            contentView.isHidden = true
            loadingIndicator.isHidden = true
            errorView.isHidden = false
            errorMessageLabel.text = errorMessage
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func retry() {
        retryAction(self)
    }
    
    private func setupLayout() {
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addSubview(errorView)
        errorView.addSubview(errorMessageLabel)
        errorView.addSubview(retryButton)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            errorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            errorMessageLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 8.0),
            errorMessageLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 8.0),
            errorMessageLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -8.0),
            errorMessageLabel.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -8.0),
            
            retryButton.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 8.0),
            retryButton.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -8.0),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -8.0)
        ])
    }
}
