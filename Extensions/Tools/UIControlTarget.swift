//
//  UIControlTarget.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit
import RxSwift
import RxCocoa

final class UIControlTarget<T>: Disposable where T: UIControlType {
    /// 回调Closure
    let eventHandler: (T, UIEvent?) -> Void
    /// 标识符
    let identifier: UIAction.Identifier
    /// 关联事件
    private let events: UIControl.Event
    /// 弱引用控件实例
    private weak var control: T?
    
    /// 初始化
    /// - Parameters:
    ///   - control: 关联的UIControl
    ///   - events: 关联的事件
    ///   - eventHandler: 事件触发回调
    init(control: T, events: UIControl.Event, _ eventHandler: @escaping (T, UIEvent?) -> Void) {
        self.eventHandler = eventHandler
        self.identifier = UIAction.Identifier(String.randomUUID)
        self.events = events
        self.control = control
        control.addTarget(self, action: #selector(action(_:event:)), for: events)
    }
    
    public func removeTargetAction() {
        control?.removeTarget(self, action: #selector(action(_:event:)), for: events)
    }
    
    /// 触发方法
    @objc private func action(_ sender: AnyObject, event: UIEvent?) {
        guard let control else { return }
        eventHandler(control, event)
    }
    
    func dispose() {
        removeTargetAction()
    }
}
