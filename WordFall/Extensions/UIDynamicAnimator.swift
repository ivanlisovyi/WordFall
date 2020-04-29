//
//  UIDynamicAnimator.swift
//  WordFall
//
//  Created by Ivan Lisovyi on 29.04.20.
//  Copyright © 2020 Ivan Lisovyi. All rights reserved.
//

import UIKit

extension UIDynamicAnimator {
    func addBehaviors(_ behaviors: [UIDynamicBehavior]) {
        behaviors.forEach { addBehavior($0) }
    }
}
