//
//  UIDynamicAnimator.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit

extension UIDynamicAnimator {
    /// Adds all the behaviors from a given array.
    /// - Parameter behaviours: The behaviors to add.
    func addBehaviors(_ behaviors: [UIDynamicBehavior]) {
        behaviors.forEach { addBehavior($0) }
    }
}
