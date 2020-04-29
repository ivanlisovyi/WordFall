//
//  LocalWordsSourceTests.swift
//  WordFallTests
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import XCTest
import Combine

@testable import WordFall

final class LocalWordsSourceTests: XCTestCase {
    var bundle: Bundle!
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        bundle = Bundle(for: Self.self)
        cancellables = Set<AnyCancellable>()
        
        super.setUp()
    }
    
    override func tearDown() {
        bundle = nil
        cancellables = nil
        
        super.tearDown()
    }
    
    func testLoadWords_wheenFileExistsAndHasCorrectFormat_shallEmitDecodedValue() {
        // Given
        let expectation = self.expectation(description: #function)
        let sut = LocalWordsSource(fileName: "tests_words.json", bundle: bundle)
        
        // When
        sut.loadWords().sink(receiveCompletion: { completion in
            switch completion {
            case .failure:
               XCTFail()
            default: break
            }
        }, receiveValue: { value in
            // Then
            XCTAssertEqual(value, self.makeExpectedResult())
            expectation.fulfill()
        }).store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testLoadWords_whenFileDoesNotExist_shallEmitError() {
        // Given
        let expectation = self.expectation(description: #function)
        let sut = LocalWordsSource(fileName: "incorrect_tests_words.json", bundle: bundle)
        
        // When
        sut.loadWords().sink(receiveCompletion: { completion in
            // Then
            
            switch completion {
            case let .failure(error):
                XCTAssertEqual(error as? WordsSourceError, WordsSourceError.fileDoesNotExist)
                expectation.fulfill()
            default: break
            }
        }, receiveValue: { value in
            XCTFail()
        }).store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testLoadWords_whenFileIsEmpty_shallEmitError() {
        // Given
        let expectation = self.expectation(description: #function)
        let sut = LocalWordsSource(fileName: "empty_words.json", bundle: bundle)
        
        // When
        sut.loadWords().sink(receiveCompletion: { completion in
            // Then
            
            switch completion {
            case let .failure(error):
                XCTAssertEqual(error as? WordsSourceError, WordsSourceError.invalidData)
                expectation.fulfill()
            default: break
            }
        }, receiveValue: { value in
            XCTFail()
        }).store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
}

extension LocalWordsSourceTests {
    func makeExpectedResult() -> [Word] {
        [
            Word(text: "primary school", translation: "escuela primaria"),
            Word(text: "teacher", translation: "profesor / profesora")
        ]
    }
}
