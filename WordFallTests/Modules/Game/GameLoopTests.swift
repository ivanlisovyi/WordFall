//
//  GameLoopTests.swift
//  WordFallTests
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import XCTest
import Combine

@testable import WordFall

final class GameLoopTests: XCTestCase {
    var mockSettings: SettingsProviding!
    var sut: GameLoop!
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        cancellables = Set<AnyCancellable>()
        
        mockSettings = Settings()
        sut = GameLoop(settings: mockSettings)
    }
    
    override func tearDown() {
        cancellables = nil
        
        sut = nil
        mockSettings = nil
        
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(sut.lifesLeft, mockSettings.lifesPerGame)
        XCTAssertEqual(sut.pointsEarned, 0)
        XCTAssertNil(sut.turn)
    }
    
    func testStartGame_whenWordsEmpty_shallReturnFalse() {
        XCTAssertFalse(sut.start(with: []))
    }
    
    func testStartGame_whenWordsAreNotEmpty_shallSendFirstTurnImmediately() {
        // Given
        let expectation = self.expectation(description: #function)
        let words = makeWords()
        
        // When
        _ = sut.start(with: words)
        
        sut.$turn
            .dropFirst()
            .sink { turn in
                XCTAssertEqual(turn?.current, words.first?.text)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidate_whenInputIsCorrect_shallIncreatePoints() {
        // Given
        let expectation = self.expectation(description: #function)
        let words = makeWords()
        let expected = 1
        
        // When
        _ = sut.start(with: words)
        
        sut.$pointsEarned
            .dropFirst()
            .sink { actual in
                XCTAssertEqual(actual, expected)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        sut.validate(words.first?.translation)
        
        // Then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testValidate_whenInputIsInCorrect_shallDecreaseLifeCount() {
        // Given
        let expectation = self.expectation(description: #function)
        let words = makeWords()
        let expected = mockSettings.lifesPerGame - 1
        
        // When
        _ = sut.start(with: words)
        
        sut.$lifesLeft
            .dropFirst()
            .sink { actual in
                XCTAssertEqual(actual, expected)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        sut.validate(nil)
        
        // Then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testWin_whenLifesCountGreaterThanZeroAndNoWordsLeft_shallBeTrue() {
        // Given
        let expectation = self.expectation(description: #function)
        let words = makeWords()
        
        // When
        _ = sut.start(with: words)
        
        sut.$isWin
            .dropFirst()
            .sink { actual in
                XCTAssertTrue(actual)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        sut.validate(words.first?.translation)
        sut.validate(words.last?.translation)
        
        // Then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testWin_whenLifesIsZeroAndNoWordsLeft_shallBeFalse() {
        // Given
        let expectation = self.expectation(description: #function)
        let words = makeWords()
        
        // When
        _ = sut.start(with: words)
        
        sut.$isWin
            .dropFirst()
            .sink { actual in
                XCTAssertFalse(actual)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        sut.validate(nil)
        sut.validate(nil)
        
        // Then
        wait(for: [expectation], timeout: 0.1)
    }
}

extension GameLoopTests {
    func makeWords() -> [Word] {
        [
            Word(text: "primary school", translation: "escuela primaria"),
            Word(text: "teacher", translation: "profesor / profesora")
        ]
    }
}
