//
//  Settings.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

/// A protocol used to define all the available game parameters.
protocol SettingsProviding {
    /// The maximum number of words per each game.
    var wordsPerGame: Int { get }
    
    /// The maximum number of lifes per each game.
    var lifesPerGame: Int { get }
    
    /// The game speed.
    ///
    /// This valus is being used as a multiplied for the initial
    /// falling word speed.
    var gameSpeed: Float { get }
}

struct Settings: SettingsProviding {
    let wordsPerGame = 10
    let lifesPerGame = 2
    let gameSpeed: Float = 1.0
}
