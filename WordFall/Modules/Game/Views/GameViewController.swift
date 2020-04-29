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
    private let gameView = GameView()
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
        setupGameView()
        setupInstructionView()
        setupErrorAlert()
        
        viewModel.prepareGame()
    }
}

// MARK: - Private Methods

fileprivate extension GameViewController {
    func setupView() {
        view.backgroundColor = Colors.background
    }
    
    func setupAcitivityIndicator() {
        view.addSubview(activityIndicator)
        
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        viewModel.$state
            .map { $0 == .loading }
            .removeDuplicates()
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
    
    func setupGameView() {
        view.addSubview(gameView)
        
        NSLayoutConstraint.activate([
            gameView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            gameView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            gameView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: statisticView.bounds.height),
            gameView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        gameView.didConfirmTranslation
            .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: false)
            .sink(receiveValue: viewModel.validate)
            .store(in: &cancellables)
        
        viewModel.$state
            .map { $0 != .started }
            .assign(to: \.isHidden, on: gameView)
            .store(in: &cancellables)
        
        viewModel.currentTurn
            .removeDuplicates()
            .sink(receiveValue: gameView.configure)
            .store(in: &cancellables)
        
        viewModel.$gameSpeed
            .sink(receiveValue: gameView.setGameSpeed)
            .store(in: &cancellables)
    }
    
    func setupInstructionView() {
        view.addSubview(instructionsView)
        
        NSLayoutConstraint.activate([
            instructionsView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            instructionsView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            instructionsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            instructionsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        viewModel.$state
            .sink(receiveValue: instructionsView.configure)
            .store(in: &cancellables)
        
        instructionsView.didHandleActionButtonTap
            .sink(receiveValue: viewModel.startGame)
            .store(in: &cancellables)
    }
    
    func setupErrorAlert() {
        viewModel.$state
            .map { state -> Error? in
                switch state {
                case let .error(error): return error
                default: return nil
                }
            }
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showErrorAlert(with: error as NSError, action: { _ in
                    self?.viewModel.prepareGame()
                })
            }.store(in: &cancellables)
    }
}

// MARK: - Error Alert Controller

private extension GameViewController {
    typealias AlertAction = (UIAlertAction) -> Void
    
    func showErrorAlert(with error: NSError, action: AlertAction? = nil) {
        let message: String? = {
            let message = [
                error.localizedFailureReason,
                error.localizedRecoverySuggestion
                ]
                .compactMap({ $0 })
                .joined(separator: "\n")
            return message.isEmpty ? nil : message
        }()
        
        let action = UIAlertAction(
            title: NSLocalizedString("general.action.ok", comment: ""),
            style: .destructive,
            handler: action
        )
        
        let alertController = UIAlertController(
            title: error.localizedDescription,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
}
