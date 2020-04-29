//
//  GameLoop.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation
import Combine

final class GameLoop: ObservableObject {
    enum Event: Equatable {
        case turn(GameTurn)
        case validate(String?)
    }
    
    let settings: SettingsProviding
    
    @Published private(set) var turn: GameTurn?
    @Published private(set) var isWin: Bool = false

    @Published private(set) var lifesLeft: Int
    @Published private(set) var pointsEarned = 0
    
    private var turns: [GameTurn] = []
    
    private var gameLoop = PassthroughSubject<Event, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(settings: SettingsProviding) {
        self.settings = settings
        
        lifesLeft = settings.lifesPerGame
        
        gameLoop
            .receive(on: RunLoop.main)
            .sink(receiveValue: processNext)
            .store(in: &cancellables)
    }
    
    /// Starts the game loop if given words array is not empty and return `true`. Return `false` otherwise.
    ///
    /// 1. Resets the game values to their defaults.
    /// 2. Take a certain number of words from `words` array.
    ///     The exact number is dictated by `settings`.
    /// 3. Starts a game by taking the very first word from the result of previous step and pushes
    ///     it through the game loop.
    ///
    /// - Parameter words: The words to pick from.
    func start(with words: [Word]) -> Bool {
        if words.isEmpty {
            return false
        }
        
        lifesLeft = settings.lifesPerGame
        pointsEarned = 0
        
        turns = pickAndMapRandomWords(from: words)
        
        let intialTurn = turns.remove(at: 0)
        gameLoop.send(.turn(intialTurn))
        
        return true 
    }
    
    /// Notifies the game loop that it needs to validate user input.
    func validate(_ input: String?) {
        gameLoop.send(.validate(input))
    }
}

fileprivate extension GameLoop {
    private func processNext(event: Event) {
        switch event {
        case let .turn(current):
            turn = current
        case let .validate(input):
            decreaseLifePointsIfNeeded(for: input)
            increasePointsIfNeeded(for: input)
            
            switch (turns.count > 0, lifesLeft > 0) {
            case (true, true):
                update(with: input)
            case (false, true):
                endGame(with: true)
            default:
                endGame(with: false)
            }
        }
    }
    
    private func update(with input: String?) {
        let nextTurn = turns.remove(at: 0)
        gameLoop.send(.turn(nextTurn))
    }
    
    private func endGame(with result: Bool) {
        isWin = result
    }
    
    private func decreaseLifePointsIfNeeded(for input: String?) {
        if input == nil || input != turn?.falling {
            lifesLeft -= 1
        }
    }
    
    private func increasePointsIfNeeded(for input: String?) {
        guard let input = input, input == turn?.falling else { return }
        pointsEarned += 1
    }
    
    func pickAndMapRandomWords(from words: [Word]) -> [GameTurn] {
        let upperBound = words.count > settings.wordsPerGame ? words.count - settings.wordsPerGame : words.count
        let wordsPerGame = min(upperBound, settings.wordsPerGame)
        
        let startIndex = Int.random(in: 0...words.count - wordsPerGame)
        let endIndex = startIndex + wordsPerGame
        let wordsSlice = words[startIndex..<endIndex]
        
        return wordsSlice.map { GameTurn(current: $0.text, falling: $0.translation) }
    }
}
