//
//  WordsSource.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Combine

/// A protocol used to define a way of loading words.
protocol WordsSource {
    /// Loads the words.
    ///
    /// - See Also: `WordsSourceError`
    /// - See Also: `Word`
    ///
    /// - Returns: A publisher with `Word` array or an error if
    ///     it's impossible to load the words for some reason.
    func loadWords() -> AnyPublisher<[Word], Error>
}
