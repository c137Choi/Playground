//
//  UIControl+Rx.swift
//
//  Created by Choi on 2023/5/15.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIControl {
    
    /// ControlEvent -> Observable<Base>
    public var touchUpInside: Observable<Base> {
        touchUpInside(toggleSelected: false)
    }
    
    /// 订阅按钮点击事件
    /// - Parameter toggleSelected: 点击时是否切换isSelected
    /// - Returns: Base序列
    public func touchUpInside(toggleSelected: Bool) -> Observable<Base> {
        controlEvent(.touchUpInside).withUnretained(base).map { base, _ in
            toggleSelected ? base.with(new: \.isSelected, base.isSelected.toggled) : base
        }
    }
    
    public var state: Observable<UIControl.State> {
        Observable.combineLatest(isEnabled, isSelected, isHighlighted)
            .withUnretained(base)
            .map(\.0.state)
            .startWith(base.state)
            .removeDuplicates
    }
    
    public var isSelected: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isSelected, options: .live).removeDuplicates
        /// 设置属性
        let valueSink = Binder(base) { base, selected in
            guard selected != base.isSelected else { return }
            base.isSelected = selected
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
    
    public var isHighlighted: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isHighlighted, options: .live).removeDuplicates
        /// 设置属性
        let valueSink = Binder(base) { base, highlighted in
            guard highlighted != base.isHighlighted else { return }
            base.isHighlighted = highlighted
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
    
    public var isEnabled: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isEnabled, options: .live).removeDuplicates
        /// 设置属性
        let valueSink = Binder(base) { base, enabled in
            guard enabled != base.isEnabled else { return }
            base.isEnabled = enabled
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
}
