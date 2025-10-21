//
//  ConstraintComponents.swift
//  KnowLED
//
//  Created by Choi on 2023/8/15.
//

import UIKit

public struct ConstraintComponents {
    let constant: Double
    let priority: UILayoutPriority
    init(constant: Double, priority: UILayoutPriority) {
        self.constant = constant
        self.priority = priority
    }
}

extension CGFloat {
    var constraint: ConstraintComponents {
        constraint(priority: .required)
    }
    func constraint(priority: UILayoutPriority) -> ConstraintComponents {
        ConstraintComponents(constant: self, priority: priority)
    }
}

extension Double {
    var constraint: ConstraintComponents {
        constraint(priority: .required)
    }
    func constraint(priority: UILayoutPriority) -> ConstraintComponents {
        ConstraintComponents(constant: self, priority: priority)
    }
}

extension Int {
    var constraint: ConstraintComponents {
        constraint(priority: .required)
    }
    func constraint(priority: UILayoutPriority) -> ConstraintComponents {
        ConstraintComponents(constant: Double(self), priority: priority)
    }
}

extension UILayoutPriority: @retroactive ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Float
    public init(floatLiteral value: FloatLiteralType) {
        self.init(rawValue: value)
    }
}

extension UILayoutPriority: @retroactive ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value.float)
    }
}
