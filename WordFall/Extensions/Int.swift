//
//  Int.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

extension Int {
    func map(_ transform: () -> String) -> String {
        var result = ""
        for _ in 0..<self {
            result.append(transform())
        }
        
        return result
    }
}
