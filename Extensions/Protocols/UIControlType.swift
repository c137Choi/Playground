//
//  UIControlType.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit
import RxSwift
import RxCocoa

typealias RxControlEventElement<T> = (T, UIEvent?)

protocol UIControlType: UIControl {}

extension UIControl: UIControlType {}

extension UIControlType {
    
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
            /// Target实例
            let target = UIControlTarget(control: self, events: events) { control, _ in
                eventHandler(control)
            }
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
                target.removeTargetAction()
                targets.remove(target)
            }
        }
    }
}

extension Reactive where Base: UIControlType {
    
    /// ControlEvent -> Observable<Base>
    var touchUpInside: Observable<Base> {
        touchUpInside(toggleSelected: false)
    }
    
    /// 订阅按钮点击事件
    /// - Parameter toggleSelected: 点击时是否切换isSelected
    /// - Returns: Base序列
    func touchUpInside(toggleSelected: Bool) -> Observable<Base> {
        controlEvent(.touchUpInside).withUnretained(base).map { base, _ in
            toggleSelected ? base.with(new: \.isSelected, base.isSelected.toggled) : base
        }
    }
    
    var state: Observable<UIControl.State> {
        Observable.combineLatest(isEnabled, isSelected, isHighlighted)
            .withUnretained(base)
            .map(\.0.state)
            .startWith(base.state)
            .removeDuplicates
    }
    
    var isSelected: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isSelected, options: .live).removeDuplicates
        /// 设置属性
        let valueSink = Binder(base) { base, selected in
            guard selected != base.isSelected else { return }
            base.isSelected = selected
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
    
    var isHighlighted: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isHighlighted, options: .live).removeDuplicates
        /// 设置属性
        let valueSink = Binder(base) { base, highlighted in
            guard highlighted != base.isHighlighted else { return }
            base.isHighlighted = highlighted
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
    
    var isEnabled: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isEnabled, options: .live).removeDuplicates
        /// 设置属性
        let valueSink = Binder(base) { base, enabled in
            guard enabled != base.isEnabled else { return }
            base.isEnabled = enabled
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
    
    /// ControlEvent元素
    typealias ControlEventElement = RxControlEventElement<Base>
    
    /// 增强的ControlEvent: 事件序列的元素返回控件和UIEvent?
    /// - Parameter controlEvents: 触发事件
    func enhancedControlEvent(_ controlEvents: UIControl.Event) -> ControlEvent<ControlEventElement> {
        let sequence = Observable<ControlEventElement>.create {
            [weak control = self.base] observer in
            /// 确保主线程运行
            MainScheduler.ensureRunningOnMainThread()
            /// 确保控件有效
            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }
            /// 创建Target并处理事件回调. 内部添加事件
            let target = UIControlTarget(control: control, events: controlEvents) { sender, event in
                let tuple: ControlEventElement = (sender, event)
                observer.onNext(tuple)
            }
            /// 销毁时执行Target的dispose方法
            return Disposables.create(with: target.removeTargetAction)
        }
        /// 事件序列
        let events = sequence.take(until: deallocated)
        /// 生成ControlEvent
        return ControlEvent(events: events)
    }
}
