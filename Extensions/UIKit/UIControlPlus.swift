//
//  UIControlPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/9.
//

import UIKit

extension UIControl {
    
    enum Associated {
        @UniqueAddress static var stateSnapshot
    }
    
    public func sendActionsIfEnabled(for controlEvents: Event) {
        guard isEnabled else { return }
        sendActions(for: controlEvents)
    }
    
    /// 是否禁用
    public var isDisabled: Bool {
        get { isEnabled.toggled }
        set { isEnabled = newValue.toggled }
    }
    
    /// 这里通过'两次'调整isEnabled以触发按钮的状态更新
    public func setStateUpdated() {
        isEnabled.toggle()
        isEnabled.toggle()
    }
    
    /// 储存UIControl的状态快照
    private var stateSnapshot: UIControl.State? {
        get {
            getAssociatedObject(self, Associated.stateSnapshot).as(UInt.self).flatMap(UIControl.State.init)
        }
        set {
            setAssociatedObject(self, Associated.stateSnapshot, newValue?.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 记录当前状态
    public func snapshotState() {
        stateSnapshot = state
    }
    
    /// 根据之前的state快照恢复状态
    public func restoreState() {
        guard let stateSnapshot = stateSnapshot.take() else { return }
        if stateSnapshot.contains(.disabled) {
            isEnabled = false
        }
        if stateSnapshot.contains(.highlighted) {
            isHighlighted = true
        }
        if stateSnapshot.contains(.selected) {
            isSelected = true
        }
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
    /// 如果要自定义UIControl, 记得覆写state属性. 如:
    /// final class CustomStatesButton: UIButton {
    ///     var customState: UIControl.State?
    ///     override var state: UIControl.State {
    ///         if let customState {
    ///             return super.state.union(customState)
    ///         } else {
    ///             return super.state
    ///         }
    ///     }
    /// }
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
