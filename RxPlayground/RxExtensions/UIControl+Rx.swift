//
//  UIControl+Rx.swift
//
//  Created by Choi on 2023/5/15.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIControl {
    
    public var state: Observable<UIControl.State> {
        Observable.combineLatest(isEnabled, isSelected, isHighlighted)
            .withUnretained(base)
            .map(\.0.state)
            .startWith(base.state)
            .removeDuplicates
    }
    
    public var isHighlighted: ControlProperty<Bool> {
        let observeIsHighlighted = observe(\.isHighlighted, options: .live)
        let binder = Binder(base, scheduler: MainScheduler.instance) { control, isHighlighted in
            guard isHighlighted != control.isHighlighted else { return }
            control.isHighlighted = isHighlighted
        }
        return ControlProperty(values: observeIsHighlighted, valueSink: binder)
    }
    
    public var isSelected: ControlProperty<Bool> {
        /// KVO观察属性变化
        let values = observe(\.isSelected, options: .live)
            .removeDuplicates //避免循环赋值
            .share(replay: 1, scope: .whileConnected)
        /// 接收属性变化
        let valueSink = Binder(base, scheduler: MainScheduler.instance) { control, isSelected in
            /// 确保值不同的时候才执行后续操作
            guard isSelected != control.isSelected else { return }
            /// 设置新值
            control.isSelected = isSelected
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
    
    public var isEnabled: ControlProperty<Bool> {
        let observeIsEnabled = observe(\.isEnabled, options: .live)
        let binder = Binder(base, scheduler: MainScheduler.instance) { control, isEnabled in
            guard isEnabled != control.isEnabled else { return }
            control.isEnabled = isEnabled
        }
        return ControlProperty(values: observeIsEnabled, valueSink: binder)
    }
}
