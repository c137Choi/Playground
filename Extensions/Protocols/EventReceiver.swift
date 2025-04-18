//
//  EventReceiver.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

protocol EventReceiver {
    associatedtype Control: UIControl
    func addEvents(_ events: UIControl.Event, _ callback: ((Control) -> Void)?) -> String
}

extension UIControl: EventReceiver {}

extension EventReceiver where Self: UIControl {
    
    
    @discardableResult
    /// 添加Closure回调
    /// - Parameters:
    ///   - events: 触发的事件集合
    ///   - callback: 回调Closure
    /// - Returns: 标记Action/ClosureWrapper的Identifier, 用于后续移除操作
    func addEvents(_ events: UIControl.Event = .touchUpInside, _ callback: ((Self) -> Void)?) -> String {
        if #available(iOS 14, *) {
            let action = UIAction { action in
                guard let callback, let sender = action.sender as? Self else { return }
                callback(sender)
            }
            addAction(action, for: events)
            return action.identifier.rawValue
        } else {
            let wrapper = ClosureWrapper(callback)
            addTarget(wrapper, action: #selector(wrapper.trigger), for: events)
            /// 因为addTarget不强引用wrapper,所以这里需要强引用
            targets.add(wrapper)
            return wrapper.identifier
        }
    }
    
    /// 移除回调Closure
    /// - Parameters:
    ///   - identifier: 添加时返回的Identifier
    ///   - events: 相关的事件
    func removeEvents(identifiedBy identifier: String, for events: UIControl.Event) {
        if #available(iOS 14.0, *) {
            removeAction(identifiedBy: UIAction.Identifier(identifier), for: events)
        } else {
            let foundWrapper = targets.as(ClosureWrapper<Self>.self).first { wrapper in
                wrapper.identifier == identifier
            }
            if let foundWrapper {
                removeTarget(foundWrapper, action: #selector(foundWrapper.trigger), for: events)
                targets.remove(foundWrapper)
            }
        }
    }
}

// MARK: - 相关类型
final class ClosureWrapper<T> where T: AnyObject {
    /// 标识符
    let identifier = String.randomUUID
    /// 回调
    var callback: ((T) -> Void)?
    
    /// 初始化方法
    /// - Parameter callback: 回调Closure
    init(_ callback: ((T) -> Void)?) {
        self.callback = callback
    }
    
    /// 触发方法
    @objc func trigger(_ sender: AnyObject) {
        guard let callback else { return }
        guard let target = sender as? T else { return }
        callback(target)
    }
}
