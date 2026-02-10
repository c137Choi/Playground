//
//  UIControlPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/9.
//

import UIKit
import RxSwift

extension UIControl {
    
    private enum Associated {
        @UniqueAddress static var customState
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
    /// 强制触发事件
    static let forceTrigger = UIControl.Event(rawValue: 1 << 24)
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

extension ReactiveCompatible where Self: UIControl {
     
    /// UIControlEventRelay别名
    fileprivate typealias EventRelay = UIControlEventRelay<Self>
    
    /// 重载事件回调
    /// - Parameters:
    ///   - targetEvents: 目标事件
    ///   - eventHandler: 事件回调闭包
    func reloadEvents(_ targetEvents: UIControl.Event = .touchUpInside, _ eventHandler: @escaping (Self) -> Void) {
        /// 移除旧事件
        enumerateEventHandlers { action, targetAction, event, stop in
            /// 确保Event匹配
            guard event == targetEvents else { return }
            /// 移除Action
            if let action {
                removeAction(action, for: event)
            }
            /// 移除Target-Action
            if let (target, action) = targetAction {
                removeTarget(target, action: action, for: event)
            }
        }
        /// 最后添加新事件
        addEvents(targetEvents, eventHandler)
    }
    
    /// 添加事件回调
    /// - Parameters:
    ///   - events: 触发的事件集合
    ///   - eventHandler: 回调Closure
    /// - Returns: UIAction.Identifier, 用于后续移除操作
    @discardableResult
    func addEvents(_ events: UIControl.Event = .touchUpInside, _ eventHandler: @escaping (Self) -> Void) -> UIAction.Identifier {
        /// 创建UIAction对象
        let action = UIAction { action in
            guard let sender = action.sender as? Self else { return }
            eventHandler(sender)
        }
        /// 添加UIAction
        addAction(action, for: events)
        /// 返回Identifier
        return action.identifier
    }
    
    /// 移除回调Closure
    /// - Parameters:
    ///   - identifier: 添加时返回的Identifier
    ///   - events: 相关的事件
    func removeEvents(identifiedBy identifier: UIAction.Identifier, for events: UIControl.Event) {
        removeAction(identifiedBy: identifier, for: events)
    }
    
    /// 添加事件 | 闭包同时返回UIEvent?对象
    /// - Parameters:
    ///   - events: 事件类型
    ///   - eventHandler: 事件回调闭包
    /// - Returns: UIAction.Identifier, 方便调用removeEnhancedEvents方法
    @discardableResult
    func enhancedEvents(_ events: UIControl.Event = .touchUpInside, _ eventHandler: @escaping (Self, UIEvent?) -> Void) -> UIAction.Identifier {
        /// EventRelay实例
        let relay = EventRelay(self, events: events, eventHandler)
        /// 强引用relay
        references[relay.identifier] = relay
        /// 返回Identifier
        return relay.identifier
    }
    
    func removeEnhancedEvents(identifiedBy identifier: UIAction.Identifier) {
        if let relay = references.removeValue(forKey: identifier).as(EventRelay.self) {
            relay.dispose()
        }
    }
}
