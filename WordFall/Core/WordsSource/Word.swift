//
//  Word.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

struct Word: Decodable {
    enum CodingKeys: String, CodingKey {
        case text = "text_eng"
        case translation = "text_spa"
    }
    
    let text: String
    let translation: String
}

extension Word: Equatable {}
