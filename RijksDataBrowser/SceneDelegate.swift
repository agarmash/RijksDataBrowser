//
//  SceneDelegate.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 23/10/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainCoordinator: ArtObjectsOverviewCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let presenter = UINavigationController()
        window.rootViewController = presenter
        
        let dependencyContainer = DependencyContainer(
            screenSize: window.frame.size)

        mainCoordinator = ArtObjectsOverviewCoordinator(
            presenter: presenter,
            dependencyContainer: dependencyContainer)
        mainCoordinator?.start()
        
        window.makeKeyAndVisible()
    }
}
