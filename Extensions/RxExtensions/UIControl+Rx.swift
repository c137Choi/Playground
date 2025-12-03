//
//  UIControl+Rx.swift
//  KnowLED
//
//  Created by Choi on 2025/8/10.
//

import UIKit
import RxSwift
import RxCocoa

typealias EnhancedControlEvent<T> = (control: T, event: UIEvent?) where T: UIControl

extension Reactive where Base: UIControl {
    
    /// ControlEvent -> RxObservable<Base>
    var touchUpInside: RxObservable<Base> {
        touchUpInside(toggleSelected: false)
    }
    
    /// 订阅按钮点击事件
    /// - Parameter toggleSelected: 点击时是否切换isSelected
    /// - Returns: Base序列
    func touchUpInside(toggleSelected: Bool) -> RxObservable<Base> {
        catchEvent(.touchUpInside, toggleSelected: toggleSelected)
    }
    
    /// 捕获事件
    /// - Parameters:
    ///   - controlEvents: 触发事件
    ///   - toggleSelected: 是否切换选中状态
    /// - Returns: Base序列
    func catchEvent(_ controlEvents: UIControl.Event, toggleSelected: Bool = false) -> RxObservable<Base> {
        controlEvent(controlEvents).withUnretained(base).map { control, _ in
            toggleSelected ? control.with(new: \.isSelected, control.isSelected.toggled) : control
        }
    }
    
    var state: RxObservable<UIControl.State> {
        RxObservable.combineLatest(isEnabled, isSelected, isHighlighted)
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
    typealias RxElement = EnhancedControlEvent<Base>
    
    /// 增强的ControlEvent: 事件序列的元素返回控件和UIEvent?
    /// - Parameter events: 触发事件
    func enhancedControlEvent(_ events: UIControl.Event) -> ControlEvent<RxElement> {
        let sequence = RxObservable<RxElement>.create {
            [weak control = self.base] observer in
            /// 确保主线程运行
            MainScheduler.ensureRunningOnMainThread()
            /// 确保控件有效
            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }
            /// 创建Target并处理事件回调. 内部添加事件
            return UIControlEventRelay(control, events: events) { sender, event in
                let tuple: RxElement = (sender, event)
                observer.onNext(tuple)
            }
        }
        /// 事件序列
        let events = sequence.take(until: deallocated)
        /// 生成ControlEvent
        return ControlEvent(events: events)
    }
}
