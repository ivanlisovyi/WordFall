//
//  GameView.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit
import Combine

final class GameView: UIView {
    static private let collisionBoundaryIdentifier = "collision.bottom.boundary"
    
    static private let fallingLabelHeight: CGFloat = 50
    static private let fallingLabelYOffset: CGFloat = 30
    
    // MARK: - Public Properties
    
    lazy var didConfirmTranslation = didConfirmTranslationSubject
        .delay(for: 0.15, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    
    // MARK: - Private Properties
    
    private var animator: UIDynamicAnimator!
    
    private lazy var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior(items: [])
        gravity.magnitude = 0.1
        return gravity
    }()
    
    private lazy var collision: UICollisionBehavior = {
        let collision = UICollisionBehavior(items: [])
        collision.collisionDelegate = self
        return collision
    }()
    
    private weak var currentFallingLabel: UILabel?
    
    private lazy var currentWordLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let didConfirmTranslationSubject = PassthroughSubject<String?, Never>()
    
    // MARK: - Init & Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCollisions()
    }
    
    private func setupCollisions() {
        collision.removeBoundary(withIdentifier: Self.collisionBoundaryIdentifier as NSCopying)
        
        collision.addBoundary(
            withIdentifier: Self.collisionBoundaryIdentifier as NSCopying,
            from: CGPoint(x: 0, y: bounds.maxY),
            to: CGPoint(x: bounds.maxX, y: bounds.maxY)
        )
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        animator = UIDynamicAnimator(referenceView: self)
        animator.addBehaviors([gravity, collision])
        
        addSubview(currentWordLabel)
        
        NSLayoutConstraint.activate([
            currentWordLabel.leftAnchor.constraint(equalTo: leftAnchor),
            currentWordLabel.rightAnchor.constraint(equalTo: rightAnchor),
            currentWordLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with turn: GameTurn) {
        reset()
        
        currentWordLabel.text = turn.current
        
        let fallingLabel = makeFallingLabel()
        fallingLabel.text = turn.falling
        fallingLabel.sizeToFit()
        fallingLabel.center = CGPoint(x: bounds.width / 2, y: Self.fallingLabelYOffset)
        
        addSubview(fallingLabel)
        
        currentFallingLabel = fallingLabel
        
        start()
    }
    
    func setGameSpeed(_ speed: Float) {
        gravity.magnitude = (0.1 * CGFloat(speed))
    }
    
    // MARK: - Touch Handling
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first, let item = currentFallingLabel else {
            return
        }
        
        let location = touch.location(in: self)
        if item.frame.contains(location) {
            item.textColor = .systemGreen
            didConfirmTranslationSubject.send(item.text)
        }
    }
}

// MARK: - Private Methods

fileprivate extension GameView {
    func start() {
        if let item = currentFallingLabel {
            addFallingBehaviours(to: item)
        }
    }
    
    func reset() {
        if let item = currentFallingLabel {
            removeFaillingBehaviors(from: item)
            item.removeFromSuperview()
        }
    }
    
    func addFallingBehaviours(to item: UIDynamicItem) {
        gravity.addItem(item)
        collision.addItem(item)
    }
    
    func removeFaillingBehaviors(from item: UIDynamicItem) {
        gravity.removeItem(item)
        collision.removeItem(item)
    }
}

// MARK: - <UICollisionBehaviorDelegate>

extension GameView: UICollisionBehaviorDelegate {
    func collisionBehavior(
        _ behavior: UICollisionBehavior,
        endedContactFor item: UIDynamicItem,
        withBoundaryIdentifier identifier: NSCopying?
    ) {
        guard let label = item as? UILabel else { return }
        
        label.textColor = .systemRed
        didConfirmTranslationSubject.send(nil)
    }
}

// MARK: - Label Factory

extension GameView {
    private func makeFallingLabel() -> UILabel {
        let frame = CGRect(x: 0, y: Self.fallingLabelYOffset, width: bounds.width, height: Self.fallingLabelHeight)
        let label = UILabel(frame: frame)
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }
}
