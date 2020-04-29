//
//  GameCoordinator.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit

final class GameCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let localWordsSource = LocalWordsSource()
        let settings = Settings()
        
        let viewModel = GameViewModel(wordsSource: localWordsSource, coordinator: self, settings: settings)
        let viewController = GameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}
