//
//  WordsSourceError.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation

/// An enum defines all the possible erros that can be raised by
///  a concrete implementation of `WordsSource` protocol.
enum WordsSourceError: Error {
    /// Thrown when it's impossible to parse a data (e.g. incorrect format).
    case invalidData
    /// Thrown when the local file doesn't exist at given path.
    case fileDoesNotExist
}
