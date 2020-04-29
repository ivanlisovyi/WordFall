//
//  Int.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

extension Int {
    /// Returns a string value by calling a supplied transform block **N** number of times
    /// and concateneting it in a single string. **N** is equal `self`.
    /// - Parameter transform: The tranform closure to be run on every iteration.
    func map(_ transform: () -> String) -> String {
        var result = ""
        for _ in 0..<self {
            result.append(transform())
        }
        
        return result
    }
}
