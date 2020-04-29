//
//  GameViewController.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit

final class GameViewController: UIViewController {
    let viewModel: GameViewModel
    
    // MARK: - Init & Lifecycle
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = Colors.background
    }
}
