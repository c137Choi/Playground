//
//  ControlEventTarget.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit
import RxSwift

final class ControlEventTarget<Control>: Disposable where Control: UIControl {
    /// 事件回调闭包
    typealias EventHandler = (Control, UIEvent?) -> Void
    
    /// 标识符
    let identifier = UIAction.Identifier(String.randomUUID)
    /// 关联事件
    private let controlEvents: UIControl.Event
    /// 回调Closure
    private var eventHandler: EventHandler?
    /// 弱引用控件实例
    private weak var control: Control?
    
    /// 初始化
    /// - Parameters:
    ///   - control: 关联的UIControl
    ///   - controlEvents: 关联的事件
    ///   - eventHandler: 事件触发回调
    init(control: Control, controlEvents: UIControl.Event, _ eventHandler: @escaping EventHandler) {
        self.control = control
        self.controlEvents = controlEvents
        self.eventHandler = eventHandler
        control.addTarget(self, action: #selector(action(_:_:)), for: controlEvents)
    }
    
    @objc private func action(_ sender: AnyObject, _ event: UIEvent?) {
        eventHandler?(sender as! Control, event)
    }
    
    func dispose() {
        control?.removeTarget(self, action: #selector(action(_:_:)), for: controlEvents)
        eventHandler = nil
    }
}
