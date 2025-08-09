//
//  UIControlType.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit
import RxSwift
import RxCocoa

protocol UIControlType: UIControl {}

extension UIControl: UIControlType {}

extension UIControlType {
    
    /// 添加事件回调
    /// - Parameters:
    ///   - controlEvents: 触发的事件集合
    ///   - eventHandler: 回调Closure
    /// - Returns: UIAction.Identifier, 用于后续移除操作
    @discardableResult
    func addEvents(_ controlEvents: UIControl.Event = .touchUpInside, _ eventHandler: @escaping (Self) -> Void) -> UIAction.Identifier {
        if #available(iOS 14, *) {
            /// 创建UIAction对象
            let action = UIAction { action in
                guard let sender = action.sender as? Self else { return }
                eventHandler(sender)
            }
            /// 添加UIAction
            addAction(action, for: controlEvents)
            /// 返回Identifier
            return action.identifier
        } else {
            /// Target实例
            let target = ControlEventTarget(control: self, controlEvents: controlEvents) { control, _ in
                eventHandler(control)
            }
            /// 强引用target
            targets[target.identifier.rawValue] = target
            /// 返回Identifier
            return target.identifier
        }
    }
    
    /// 移除回调Closure
    /// - Parameters:
    ///   - identifier: 添加时返回的Identifier
    ///   - controlEvents: 相关的事件
    func removeEvents(identifiedBy identifier: UIAction.Identifier, for controlEvents: UIControl.Event) {
        if #available(iOS 14.0, *) {
            removeAction(identifiedBy: identifier, for: controlEvents)
        } else {
            if let target = targets.removeValue(forKey: identifier.rawValue).as(ControlEventTarget<Self>.self) {
                target.dispose()
            }
        }
    }
}
