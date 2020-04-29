//
//  GameViewModelTests.swift
//  WordFallTests
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import XCTest
import Combine

@testable import WordFall

final class GameViewModelTests: XCTestCase {
    var mockWordsSource: WordsSource!
    var mockCoordinator: Coordinator!
    var mockSetting: SettingsProviding!
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        mockWordsSource = MockWordsSource()
        mockCoordinator = MockCoordinator()
        mockSetting = Settings()
        
        cancellables = Set<AnyCancellable>()
        
        super.setUp()
    }
    
    override func tearDown() {
        mockWordsSource = nil
        mockCoordinator = nil
        mockSetting = nil
        
        cancellables = nil
        
        super.tearDown()
    }
    
    func testInitialState() {
        // When
        let sut = GameViewModel(
            wordsSource: mockWordsSource,
            coordinator: mockCoordinator,
            settings: mockSetting
        )
        
        let lifesValue = CurrentValueSubject<String?, Never>(nil)
        sut.lifesLeftString
            .subscribe(lifesValue)
            .store(in: &cancellables)
        
        let pointsValue = CurrentValueSubject<String?, Never>(nil)
        sut.pointsEarnedString
            .subscribe(pointsValue)
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(sut.state, GameViewModel.ViewState.loading)
        XCTAssertEqual(sut.gameSpeed, mockSetting.gameSpeed, accuracy: 0.0001)
        
        XCTAssertEqual(lifesValue.value, "♥︎♥︎")
        XCTAssertEqual(pointsValue.value, "\("game.score".localized()) 0")
    }
    
    func testPrepareGame_whenLoadWordsSuccesfully_shallChangeStateToReady() {
        // Given
        let sut = GameViewModel(
            wordsSource: mockWordsSource,
            coordinator: mockCoordinator,
            settings: mockSetting
        )
        
        // When
        let actual = CurrentValueSubject<GameViewModel.ViewState, Never>(.loading)
        sut.$state
            .subscribe(actual)
            .store(in: &cancellables)

        sut.prepareGame()
        
        // Then
        XCTAssertEqual(actual.value, GameViewModel.ViewState.ready)
    }
    
    func testStartGame_whenGameStart_shallChangeStateToStarted() {
        // Given
        let sut = GameViewModel(
            wordsSource: mockWordsSource,
            coordinator: mockCoordinator,
            settings: mockSetting
        )
        
        // When
        let actual = CurrentValueSubject<GameViewModel.ViewState, Never>(.ready)
        sut.$state
            .subscribe(actual)
            .store(in: &cancellables)
        
        sut.startGame()
        
        // Then
        XCTAssertEqual(actual.value, GameViewModel.ViewState.started)
    }
}

final class MockCoordinator: Coordinator {
    func start() {}
}

final class MockWordsSource: WordsSource {
    func loadWords() -> AnyPublisher<[Word], Error> {
        Just([
            Word(text: "primary school", translation: "escuela primaria"),
            Word(text: "teacher", translation: "profesor / profesora")
        ])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
