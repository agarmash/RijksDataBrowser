//
//  LoadableErrorableView.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 29/10/2023.
//

import UIKit

class LoadableErrorableView: UIView {
    
    enum State {
        case empty
        case loading
        case presentingContent
        case error(String)
    }
    
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
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        return button
    }()
    
//    private var state: State = .loading
    private let retryAction: (LoadableErrorableView) -> Void

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
    
    @objc func retry() {
        retryAction(self)
    }
    
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
            errorView.topAnchor.constraint(equalTo: topAnchor),
            errorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            errorMessageLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 8.0),
            errorMessageLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 8.0),
            errorMessageLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: 8.0),
            errorMessageLabel.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: 24.0),
            
            retryButton.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 8.0),
            retryButton.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: 8.0),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: 8.0)
        ])
    }
}
