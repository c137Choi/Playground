//
//  UIControlPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/9.
//

import UIKit

extension UIControl {
    
    private enum Associated {
        @UniqueAddress static var customState
    }
    
    public func sendActionsIfEnabled(for controlEvents: Event) {
        guard isEnabled else { return }
        sendActions(for: controlEvents)
    }
    
    public var customState: State {
        get {
            getAssociatedObject(self, Associated.customState).as(UInt.self).flatMap(State.init) ?? []
        }
        set {
            setAssociatedObject(self, Associated.customState, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
            setStateUpdated()
        }
    }
    
    /// 是否禁用
    public var isDisabled: Bool {
        get { isEnabled.toggled }
        set { isEnabled = newValue.toggled }
    }
    
    /// 是否为受限状态
    /// 设置isRestricted为true而不是将isEnabled设置为false, 方便实现受限状态下控件仍然可交互
    var isRestricted: Bool {
        get {
            customState.contains(.restricted)
        }
        set {
            if newValue {
                customState.formUnion(.restricted)
            } else {
                customState.subtract(.restricted)
            }
        }
    }
    
    /// 通过'两次'调整isEnabled以触发按钮的状态更新
    public func setStateUpdated() {
        isEnabled.toggle()
        isEnabled.toggle()
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
    /// UIControl受限状态
    static let restricted = UIControl.State(rawValue: 1 << 16)
    /// 方便自定义状态的时候调用: .customState.andHighlighted
    public var andHighlighted: UIControl.State {
        union(.highlighted)
    }
}

extension UIControl.State: @retroactive Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension UIControl.State {
    /// 可用范围比特位为: UIControl.State.application
    /// 即: 0b0000_0000_1111_1111_0000_0000_0000_0000, 向左移位16-23为合法范围
    /// 注: 如果需要外部触发UIControl的状态变化, 可以调用自定义的UIControl.setStateUpdated()扩展方法
    /// 如果要自定义UIControl, 记得覆写父类的state属性.
    private static let state16 = UIControl.State(rawValue: 1 << 16)
    private static let state17 = UIControl.State(rawValue: 1 << 17)
    private static let state18 = UIControl.State(rawValue: 1 << 18)
    private static let state19 = UIControl.State(rawValue: 1 << 19)
    private static let state20 = UIControl.State(rawValue: 1 << 20)
    private static let state21 = UIControl.State(rawValue: 1 << 21)
    private static let state22 = UIControl.State(rawValue: 1 << 22)
    private static let state23 = UIControl.State(rawValue: 1 << 23)
}

extension UIControl.Event {
    /// 可用范围比特位为: UIControl.Event.applicationReserved
    /// 即: 0b0000_1111_0000_0000_0000_0000_0000_0000, 向左移位24-27为合法范围
    private static let event24 = UIControl.Event(rawValue: 1 << 24)
    private static let event25 = UIControl.Event(rawValue: 1 << 25)
    private static let event26 = UIControl.Event(rawValue: 1 << 26)
    private static let event27 = UIControl.Event(rawValue: 1 << 27)
}
