//
//  GameInstructionsView.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit
import Combine

final class GameInstructionsView: UIView {
    private static let buttonWidth: CGFloat = 200
    private static let buttonHeight: CGFloat = 50
    private static let buttonCornerRadius: CGFloat = 25
    
    private static let elementSpacing: CGFloat = 15
    
    // MARK: - Public Properties
    
    let didHandleActionButtonTap = PassthroughSubject<Void, Never>()
    
    // MARK: - Private Properties
    
    private lazy var startButton: UIButton = {
        let button = makeButton(
            buttonColor: Colors.primaryButton
        )
        button.addTarget(self, action: #selector(startButtonHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        makeLabel(with: .preferredFont(forTextStyle: .title1))
    }()
    
    private lazy var detailLabel: UILabel = {
        makeLabel(with: .preferredFont(forTextStyle: .body))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel, startButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Self.elementSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .red
        
        addSubview(stackView)
        
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    // MARK: - Public Methods
    
    func configure(with state: GameViewModel.ViewState) {
        if case let .finished(isWin) = state {
            titleLabel.text = isWin ? "game.won.text".localized() : "game.lost.text".localized()
            detailLabel.text = "game.reset.instructions".localized()
            startButton.setTitle("game.reset.button.title".localized(), for: .normal)
            startButton.backgroundColor = Colors.secondaryButton
            isHidden = false
        } else {
            titleLabel.text = "game.name".localized()
            detailLabel.text = "game.play.instructions".localized()
            startButton.setTitle("game.start.button.title".localized(), for: .normal)
            startButton.backgroundColor = Colors.primaryButton
            isHidden = state != .ready
        }
    }
    
    // MARK: - Action Handlers
    
    @objc private func startButtonHandler() {
        didHandleActionButtonTap.send()
    }
}

fileprivate extension GameInstructionsView {
    func makeLabel(with font: UIFont) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = Colors.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func makeButton(
        titleColor: UIColor? = Colors.label,
        buttonColor: UIColor?
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = buttonColor
        button.setTitleColor(titleColor, for: .normal)
        button.setTitleColor(titleColor?.withAlphaComponent(0.75), for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: Self.buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: Self.buttonHeight).isActive = true
        button.layer.cornerRadius = Self.buttonCornerRadius
        button.adjustsImageWhenHighlighted = true
        
        return button
    }
}
