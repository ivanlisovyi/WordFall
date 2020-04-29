//
//  LocalWordsSource.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation
import Combine

/// A class the provides a way to get an array of `Words` from a given file.
struct LocalWordsSource: WordsSource {
    let fileName: String
    let bundle: Bundle
    
    let decoder: JSONDecoder
    
    /// Create a local words source with a given parameters.
    /// - Parameters:
    ///     - fileName: The name of the source file. Defaults to `words.json`.
    ///     - bundle: The file's bundle. Defaults to `.main`.
    ///     - decoder: The data decoder. Defaults to `JSONDecoder()`.
    init(
        fileName: String = "words.json",
        bundle: Bundle = .main,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileName = fileName
        self.bundle = bundle
        self.decoder = decoder
    }
    
    func loadWords() -> AnyPublisher<[Word], Error> {
        Future<[Word], Error> { promise in
            guard let path = self.bundle.path(forResource: self.fileName, ofType: "") else {
                promise(.failure(WordsSourceError.fileDoesNotExist))
                return
            }
            
            let fileURL = URL(fileURLWithPath: path)

            do {
                let data = try Data(contentsOf: fileURL)
                let result = try self.decoder.decode([Word].self, from: data)
                promise(.success(result))
            } catch {
                promise(.failure(WordsSourceError.invalidData))
            }
        }.eraseToAnyPublisher()
    }
}
