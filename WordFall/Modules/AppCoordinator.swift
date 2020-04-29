//
//  AppCoordinator.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator {
    let window: UIWindow
    
    let navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        return navigationController
    }()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let coordinator = GameCoordinator(navigationController: navigationController)
        coordinator.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
