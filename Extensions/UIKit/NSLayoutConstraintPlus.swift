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
    
    /// 是否为固定宽度约束
    var isFixWidthConstraint: Bool {
        guard firstAttribute == .width else { return false }
        guard relation == .equal else { return false }
        guard secondAttribute == .notAnAttribute else { return false }
        return true
    }
    
    /// 是否为固定高度约束
    var isFixHeightConstraint: Bool {
        guard firstAttribute == .height else { return false }
        guard relation == .equal else { return false }
        guard secondAttribute == .notAnAttribute else { return false }
        return true
    }
    
    /// 是否为最小宽度约束
    var isMinWidthConstraint: Bool {
        guard firstAttribute == .width else { return false }
        guard relation == .greaterThanOrEqual else { return false }
        guard secondAttribute == .notAnAttribute else { return false }
        return true
    }
    
    /// 是否为最大宽度约束
    var isMaxWidthConstraint: Bool {
        guard firstAttribute == .width else { return false }
        guard relation == .lessThanOrEqual else { return false }
        guard secondAttribute == .notAnAttribute else { return false }
        return true
    }
    
    /// 是否为最小高度约束
    var isMinHeightConstraint: Bool {
        guard firstAttribute == .height else { return false }
        guard relation == .greaterThanOrEqual else { return false }
        guard secondAttribute == .notAnAttribute else { return false }
        return true
    }
    
    /// 是否为最大高度约束
    var isMaxHeightConstraint: Bool {
        guard firstAttribute == .height else { return false }
        guard relation == .lessThanOrEqual else { return false }
        guard secondAttribute == .notAnAttribute else { return false }
        return true
    }
}
