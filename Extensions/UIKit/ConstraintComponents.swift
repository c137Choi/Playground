//
//  ConstraintComponents.swift
//  KnowLED
//
//  Created by Choi on 2023/8/15.
//

import UIKit

public struct ConstraintComponents {
    /// 常量
    let constant: CGFloat
    /// 优先级
    let priority: UILayoutPriority
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
        ConstraintComponents(constant: CGFloat(self), priority: priority)
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
