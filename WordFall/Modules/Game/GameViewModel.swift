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
    let wordsSource: WordsSource
    let coordinator: Coordinator
    let settings: SettingsProviding
    
    // MARK: - Init
    
    init(wordsSource: WordsSource, coordinator: Coordinator, settings: SettingsProviding) {
        self.wordsSource = wordsSource
        self.coordinator = coordinator
        self.settings = settings
    }
}
