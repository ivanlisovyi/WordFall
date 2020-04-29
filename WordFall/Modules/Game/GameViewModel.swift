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
        case finished(Bool)
    }
    
    @Published private(set) var state: ViewState = .loading

    let wordsSource: WordsSource
    let coordinator: Coordinator
    let settings: SettingsProviding
    
    // MARK: - Private Properties
    
    private var words: [Word] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(wordsSource: WordsSource, coordinator: Coordinator, settings: SettingsProviding) {
        self.wordsSource = wordsSource
        self.coordinator = coordinator
        self.settings = settings
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
        state = .started
    }
}
