//
//  MainCoordinator.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 26/10/2023.
//

import UIKit

protocol CoordinatorProtocol {
    func start()
}

class MainCoordinator: CoordinatorProtocol {

    // MARK: - Private Properties

    private let window: UIWindow

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public Methods

    func start() {
        let presenter = UINavigationController()
        window.rootViewController = presenter

        let viewModel = ArtObjectsOverviewViewModel(
            action: { _ in },
            repository: ArtObjectsRepository(dataService: RijksDataService(client: NetworkClient())))
        let viewController = ArtObjectsOverviewViewController(viewModel: viewModel)
        presenter.pushViewController(viewController, animated: false)
        window.makeKeyAndVisible()
    }
}
