//
//  Word.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

/// A struct that represent a single word in a word source.
struct Word: Decodable {
    enum CodingKeys: String, CodingKey {
        case text = "text_eng"
        case translation = "text_spa"
    }
    
    /// The original text.
    let text: String
    
    /// The original text translation.
    let translation: String
}

extension Word: Equatable {}
