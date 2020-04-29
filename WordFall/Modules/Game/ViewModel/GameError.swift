//
//  GameError.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

enum GameError: LocalizedError {
    case emptyData
    
    var errorDescription: String? {
        switch self {
        case .emptyData: return "game.words.source.empty.error".localized()
        }
    }
}
