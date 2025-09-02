//
//  UIControlPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/9.
//

import UIKit

extension UIControl {
    
    var isDisabled: Bool {
        get { !isEnabled }
        set(disabled) { isEnabled = !disabled }
    }
}

extension UIControl.Event {
    /// touchUpInside(Outside)
    static let touchUp: UIControl.Event = [.touchUpInside, .touchUpOutside]
    /// touchDragInside(Outside)
    static let touchDrag: UIControl.Event = [.touchDragInside, .touchDragOutside]
    /// touchDownDragInside(Outside)
    static let touchDownDrag: UIControl.Event = [.touchDown, .touchDrag]
}

extension UIControl.State: @retroactive Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension UIControl.State: @retroactive CustomDebugStringConvertible {
    
    public var debugDescription: String {
        if isEmpty { return "empty" }
        var desc = ""
        if contains(.normal) {
            desc += "normal, "
        }
        if contains(.highlighted) {
            desc += "highlighted, "
        }
        if contains(.disabled) {
            desc += "disabled, "
        }
        if contains(.selected) {
            desc += "selected, "
        }
        if contains(.focused) {
            desc += "focused, "
        }
        if contains(.application) {
            desc += "application, "
        }
        if contains(.reserved) {
            desc += "reserved, "
        }
        /// 移除逗号+空格
        desc.removeLast(2)
        return desc
    }
}
