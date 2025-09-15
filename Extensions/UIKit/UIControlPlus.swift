//
//  UIControlPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/9.
//

import UIKit

extension UIControl {
    
    /// 是否禁用
    public var isDisabled: Bool {
        get { isEnabled.toggled }
        set { isEnabled = newValue.toggled }
    }
}

extension UIControl.Event {
    /// 表示由用户直接交互而产生的事件
    static let userInteraction = UIControl.Event(rawValue: 1 << 24)
    /// 按下抬起
    public static let touchUp: UIControl.Event = [.touchUpInside, .touchUpOutside]
    /// 按下 + 内(外)拖动
    public static let touchDownDrag: UIControl.Event = [.touchDown, .touchDragInside, .touchDragOutside]
}

extension UIControl.State {
    
    /// 方便自定义状态的时候调用: .customState.unionHighlighted
    public var unionHighlighted: UIControl.State {
        union(.highlighted)
    }
}

extension UIControl.State: @retroactive Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
