//
//  GameViewModel.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation
import Combine

struct Turn: Equatable {
    let current: String
    let falling: String
}

final class GameViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case ready
        case started
        case finished(Bool)
    }
    
    lazy var lifesLeftString: AnyPublisher<String?, Never> = {
        $lifesLeft.map { $0.map { "♥︎" } }.eraseToAnyPublisher()
    }()
    
    lazy var pointsEarnedString: AnyPublisher<String?, Never> = {
        $pointsEarned.map {"\("game.score".localized()) \($0)"}.eraseToAnyPublisher()
    }()
    
    @Published private(set) var currentTurn: Turn?
    @Published private(set) var state: ViewState = .loading
    @Published private(set) var gameSpeed: Float

    let wordsSource: WordsSource
    let coordinator: Coordinator
    let settings: SettingsProviding
    
    // MARK: - Private Properties
    
    @Published private var lifesLeft: Int
    @Published private var pointsEarned = 0
    
    private var words: [Word] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(wordsSource: WordsSource, coordinator: Coordinator, settings: SettingsProviding) {
        self.wordsSource = wordsSource
        self.coordinator = coordinator
        self.settings = settings
        
        self.lifesLeft = settings.lifesPerGame
        self.gameSpeed = settings.gameSpeed
    }
    
    // MARK: - Public Methods
    
    func prepareGame() {
        wordsSource.loadWords()
            .handleEvents(receiveOutput: { [weak self] in
                if let self = self {
                    self.words = $0
                }
            })
            .replaceError(with: [])
            .map { _ in return ViewState.ready }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
    
    func startGame() {
        resetGame()
        
        state = .started
    }
    
    func validate(_ input: String?) {
        
    }
}

// MARK: - Private Methods

fileprivate extension GameViewModel {
    private func resetGame() {
        
    }
}
