//
//  LocalWordsSource.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Foundation
import Combine

struct LocalWordsSource: WordsSource {
    let fileName: String
    let bundle: Bundle
    
    let decoder: JSONDecoder
    
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
