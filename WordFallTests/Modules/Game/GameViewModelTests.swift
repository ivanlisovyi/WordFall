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
    
    var sut: GameViewModel!
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        mockWordsSource = MockWordsSource()
        mockCoordinator = MockCoordinator()
        mockSetting = Settings()
        
        sut = GameViewModel(
            wordsSource: mockWordsSource,
            coordinator: mockCoordinator,
            settings: mockSetting
        )
        
        cancellables = Set<AnyCancellable>()
        
        super.setUp()
    }
    
    override func tearDown() {
        mockWordsSource = nil
        mockCoordinator = nil
        mockSetting = nil
        
        sut = nil
        
        cancellables = nil
        
        super.tearDown()
    }
    
    func testInitialState() {
        // When
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
        let expectation = self.expectation(description: #function)
 
        // When
        sut.$state
            .removeDuplicates()
            .collect(2)
            .sink {
                // Then
                XCTAssertEqual($0, [GameViewModel.ViewState.loading, GameViewModel.ViewState.ready])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.prepareGame()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testStartGame_whenGameStart_shallChangeStateToStarted() {
        // Given
        let expectation = self.expectation(description: #function)

        // When
        sut.$state
            .sink { [weak self] state in
                switch state {
                case .ready: self?.sut.startGame()
                case .started:
                    expectation.fulfill()
                case .error:
                    XCTFail()
                default: break
                }
            }
            .store(in: &cancellables)
        
        sut.prepareGame()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testStartGame_whenGameStartAndDataIsEmpty_shallChangeStateToError() {
        // Given
        let expectation = self.expectation(description: #function)
        
        // When
        sut.$state
            .dropFirst()
            .sink { state in
                // Then
                switch state {
                case .error:
                    expectation.fulfill()
                default:
                    XCTFail()
                }
        }
        .store(in: &cancellables)
        
        sut.startGame()
        
        wait(for: [expectation], timeout: 0.1)
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
