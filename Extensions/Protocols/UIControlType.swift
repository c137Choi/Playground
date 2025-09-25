//
//  UIControlType.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit

protocol UIControlType: UIControl {}

extension UIControl: UIControlType {}

extension UIControlType {
    
    @available(iOS 14.0, *)
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
        if #available(iOS 14, *) {
            /// 创建UIAction对象
            let action = UIAction { action in
                guard let sender = action.sender as? Self else { return }
                eventHandler(sender)
            }
            /// 添加UIAction
            addAction(action, for: events)
            /// 返回Identifier
            return action.identifier
        } else {
            /// Relay实例
            let relay = UIControlEventRelay(self, events: events) { control, _ in
                eventHandler(control)
            }
            /// 强引用Relay
            targets[relay.identifier] = relay
            /// 返回Identifier
            return relay.identifier
        }
    }
    
    /// 移除回调Closure
    /// - Parameters:
    ///   - identifier: 添加时返回的Identifier
    ///   - events: 相关的事件
    func removeEvents(identifiedBy identifier: UIAction.Identifier, for events: UIControl.Event) {
        if #available(iOS 14.0, *) {
            removeAction(identifiedBy: identifier, for: events)
        } else {
            if let target = targets.removeValue(forKey: identifier).as(UIControlEventRelay<Self>.self) {
                target.dispose()
            }
        }
    }
    
    /// 添加事件 | 闭包同时返回UIEvent?对象
    /// - Parameters:
    ///   - events: 事件类型
    ///   - eventHandler: 事件回调闭包
    /// - Returns: UIAction.Identifier, 方便调用
    @discardableResult
    func enhancedEvents(_ events: UIControl.Event = .touchUpInside, _ eventHandler: @escaping (Self, UIEvent?) -> Void) -> UIAction.Identifier {
        /// Target实例
        let target = UIControlEventRelay(self, events: events, eventHandler)
        /// 强引用target
        targets[target.identifier] = target
        /// 返回Identifier
        return target.identifier
    }
    
    func removeEnhancedEvents(identifiedBy identifier: UIAction.Identifier) {
        if let target = targets.removeValue(forKey: identifier).as(UIControlEventRelay<Self>.self) {
            target.dispose()
        }
    }
}
