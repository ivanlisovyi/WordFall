//
//  GameViewController.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit
import Combine

final class GameViewController: UIViewController {
    let viewModel: GameViewModel
    
    // MARK: - Private Properties
    
    private let statisticView = GameStatisticView()
    private let instructionsView = GameInstructionsView()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tintColor = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        setupAcitivityIndicator()
        setupStatisticView()
        setupInstructionView()
        
        viewModel.prepareGame()
    }

    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = Colors.background
    }
    
    func setupAcitivityIndicator() {
        view.addSubview(activityIndicator)
        
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        viewModel.$state
            .map { $0 == .loading }
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
        }.store(in: &cancellables)
    }
    
    func setupStatisticView() {
        view.addSubview(statisticView)
        
        viewModel.lifesLeftString
            .sink(receiveValue: statisticView.setLifesCountText)
            .store(in: &cancellables)
        
        viewModel.pointsEarnedString
            .sink(receiveValue: statisticView.setScoreText)
            .store(in: &cancellables)
        
        NSLayoutConstraint.activate([
            statisticView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            statisticView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            statisticView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        ])
    }
    
    func setupInstructionView() {
        view.addSubview(instructionsView)
        
        NSLayoutConstraint.activate([
            instructionsView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            instructionsView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            instructionsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            instructionsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        viewModel
            .$state
            .sink(receiveValue: instructionsView.configure)
            .store(in: &cancellables)
        
        instructionsView.didHandleActionButtonTap
            .sink(receiveValue: viewModel.startGame)
            .store(in: &cancellables)
    }
}
