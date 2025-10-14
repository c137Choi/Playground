//
//  NSLayoutConstraintPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/10/14.
//

import UIKit

extension NSLayoutConstraint {
    
    static func activate(@ArrayBuilder<NSLayoutConstraint> constraintsBuilder: () -> Array<NSLayoutConstraint>) {
        let constraints = constraintsBuilder()
        activate(constraints)
    }
    
    static func deactivate(@ArrayBuilder<NSLayoutConstraint> _ constraintsBuilder: () -> Array<NSLayoutConstraint>) {
        let constraints = constraintsBuilder()
        deactivate(constraints)
    }
}
