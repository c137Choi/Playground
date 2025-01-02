//
//  UIView+Rx.swift
//
//  Created by Choi on 2022/8/18.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    
    /// 实时观察Frame变化
    var frame: Observable<CGRect> {
        let observables = Array {
            observe(\.frame)
            base.layer.rx.observe(\.frame).withUnretained(base).map(\.0.frame)
            base.layer.rx.observe(\.bounds).withUnretained(base).map(\.0.frame)
            base.layer.rx.observe(\.transform).withUnretained(base).map(\.0.frame)
            base.layer.rx.observe(\.position).withUnretained(base).map(\.0.frame)
            base.layer.rx.observe(\.zPosition).withUnretained(base).map(\.0.frame)
            base.layer.rx.observe(\.anchorPoint).withUnretained(base).map(\.0.frame)
            base.layer.rx.observe(\.anchorPointZ).withUnretained(base).map(\.0.frame)
        }
        return observables.merged
    }
    
    var intrinsicContentSize: Observable<CGSize> {
        didLayoutSubviews.map(\.intrinsicContentSize)
    }
    
    var windowSequence: Observable<UIWindow?> {
        didMoveToWindow.startWith(base.window)
    }
    
    var didMoveToWindow: Observable<UIWindow?> {
        methodInvoked(#selector(base.didMoveToWindow))
            .withUnretained(base)
            .map(\.0.window)
    }
    
    var willMoveToWindow: Observable<UIWindow?> {
        methodInvoked(#selector(base.willMove(toWindow:)))
            .map(\.first)
            .asOptional(UIWindow.self)
    }
    
    var willMoveToSuperView: Observable<UIView?> {
        methodInvoked(#selector(base.willMove(toSuperview:)))
            .map(\.first)
            .asOptional(UIView.self)
    }
    
    var removeFromSuperview: Observable<[Any]> {
        methodInvoked(#selector(base.removeFromSuperview))
    }

    var didLayoutSubviews: Observable<Base> {
        methodInvoked(#selector(base.layoutSubviews))
            .withUnretained(base)
            .map(\.0)
    }
    
    var superView: Observable<UIView?> {
        methodInvoked(#selector(base.didMoveToSuperview))
            .withUnretained(base)
            .map(\.0.superview)
            .startWith(base.superview)
            .removeDuplicates
    }
    
    var isVisible: Observable<Bool> {
        methodInvoked(#selector(base.didMoveToWindow))
            .withUnretained(base)
            .map(\.0.window.isValid)
            .removeDuplicates
            .observe(on: MainScheduler.instance)
    }
}
