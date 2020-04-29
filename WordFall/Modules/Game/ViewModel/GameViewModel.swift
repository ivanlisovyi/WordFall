//
//  GameViewModel.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation
import Combine

/// A view model that represents a current game state and a current game view state. 
final class GameViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case ready
        case started
        case finished(isWin: Bool)
        case error(GameError)
    }
    
    /// The string repsentation of the user's remaining lifes count.
    var lifesLeftString: AnyPublisher<String?, Never> {
        gameLoop.$lifesLeft
            .map { $0.map { "♥︎" } }
            .eraseToAnyPublisher()
    }
    
    /// The string representation of the user's earned points value. Localized.
    var pointsEarnedString: AnyPublisher<String?, Never> {
        gameLoop.$pointsEarned
            .map {"\("game.score".localized()) \($0)"}
            .eraseToAnyPublisher()
    }
    
    /// The current game turn.
    var currentTurn: AnyPublisher<GameTurn, Never> {
        gameLoop.$turn
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// The current view state. Default to `.loading`.
    @Published private(set) var state: ViewState = .loading
    /// The current game speed.
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
    
    /// Loads a words from a give words source and changes state to `.ready` afterwards.
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
    
    /// Starts a game if words are available and change the state to `.started`
    /// or changes the state to `.error` otherwise.
    func startGame() {
        guard gameLoop.start(with: words) else {
            state = .error(.emptyData)
            return
        }
        
        state = .started
    }
    
    /// Validate user input
    /// - Parameter input: The user's input. The empty value indicates that user missed the word.
    func validate(_ input: String?) {
        gameLoop.validate(input)
    }
}
