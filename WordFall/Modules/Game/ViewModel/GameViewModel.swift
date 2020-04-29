//
//  GameViewModel.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation
import Combine

final class GameViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case ready
        case started
        case finished(isWin: Bool)
        case error(GameError)
    }
    
    var lifesLeftString: AnyPublisher<String?, Never> {
        gameLoop.$lifesLeft
            .map { $0.map { "♥︎" } }
            .eraseToAnyPublisher()
    }
    
    var pointsEarnedString: AnyPublisher<String?, Never> {
        gameLoop.$pointsEarned
            .map {"\("game.score".localized()) \($0)"}
            .eraseToAnyPublisher()
    }
    
    var currentTurn: AnyPublisher<GameTurn, Never> {
        gameLoop.$turn.compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    @Published private(set) var state: ViewState = .loading
    @Published private(set) var gameSpeed: Float

    let wordsSource: WordsSource
    let coordinator: Coordinator
    let settings: SettingsProviding
    
    private let gameLoop: GameLoop
    
    // MARK: - Private Properties
    
    private var words: [Word] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(wordsSource: WordsSource, coordinator: Coordinator, settings: SettingsProviding) {
        self.wordsSource = wordsSource
        self.coordinator = coordinator
        self.settings = settings
        
        self.gameSpeed = settings.gameSpeed
        self.gameLoop = GameLoop(settings: settings)
        self.gameLoop.$isWin
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.state = .finished(isWin: $0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func prepareGame() {
        state = .loading
        
        wordsSource.loadWords()
            .receive(on: DispatchQueue.main)
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
        guard gameLoop.start(with: words) else {
            state = .error(.emptyData)
            return
        }
        
        state = .started
    }
    
    func validate(_ input: String?) {
        gameLoop.validate(input)
    }
}
