//
//  WordsSource.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import Combine

protocol WordsSource {
    func loadWords() -> AnyPublisher<[Word], Error>
}
