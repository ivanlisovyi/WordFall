//
//  Settings.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

protocol SettingsProviding {
    var wordsPerGame: Int { get }
    var lifesPerGame: Int { get }
    
    var gameSpeed: Float { get }
}

struct Settings: SettingsProviding {
    let wordsPerGame = 10
    let lifesPerGame = 2
    let gameSpeed: Float = 1.0
}
