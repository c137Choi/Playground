//
//  UIControlType.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit

protocol UIControlType: UIControl {}

extension UIControl: UIControlType {}

extension UIControlType where Self: UIControl {
    
    /// 添加事件回调
    /// - Parameters:
    ///   - events: 触发的事件集合
    ///   - handler: 回调Closure
    /// - Returns: UIAction.Identifier, 用于后续移除操作
    @discardableResult
    func addEvents(_ events: UIControl.Event = .touchUpInside, _ handler: @escaping (Self) -> Void) -> UIAction.Identifier {
        if #available(iOS 14, *) {
            /// 创建UIAction对象
            let action = UIAction { action in
                guard let sender = action.sender as? Self else { return }
                handler(sender)
            }
            /// 添加UIAction
            addAction(action, for: events)
            /// 返回Identifier
            return action.identifier
        } else {
            /// Target实例
            let target = UIControlTarget(handler)
            /// 为events添加回调
            addTarget(target, action: #selector(target.trigger), for: events)
            /// 强引用target
            targets.add(target)
            /// 返回Identifier
            return target.identifier
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
            let target = targets.lazy.as(UIControlTarget<Self>.self).first { eachTarget in
                eachTarget.identifier == identifier
            }
            if let target {
                removeTarget(target, action: #selector(target.trigger), for: events)
                targets.remove(target)
            }
        }
    }
}
