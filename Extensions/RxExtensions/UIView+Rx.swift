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
    var frame: RxObservable<CGRect> {
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
    
    var intrinsicContentSize: RxObservable<CGSize> {
        didLayoutSubviews.map(\.intrinsicContentSize)
    }
    
    var windowSequence: RxObservable<UIWindow?> {
        didMoveToWindow.startWith(base.window)
    }
    
    var didMoveToWindow: RxObservable<UIWindow?> {
        methodInvoked(#selector(UIView.didMoveToWindow))
            .withUnretained(base)
            .map(\.0.window)
    }
    
    var willMoveToWindow: RxObservable<UIWindow?> {
        methodInvoked(#selector(UIView.willMove(toWindow:)))
            .map(\.first)
            .asOptional(UIWindow.self)
    }
    
    var willMoveToSuperView: RxObservable<UIView?> {
        methodInvoked(#selector(UIView.willMove(toSuperview:)))
            .map(\.first)
            .asOptional(UIView.self)
    }
    
    var removeFromSuperview: RxObservable<[Any]> {
        methodInvoked(#selector(UIView.removeFromSuperview))
    }

    var didLayoutSubviews: RxObservable<Base> {
        methodInvoked(#selector(UIView.layoutSubviews))
            .withUnretained(base)
            .map(\.0)
    }
    
    var superView: RxObservable<UIView?> {
        methodInvoked(#selector(UIView.didMoveToSuperview))
            .withUnretained(base)
            .map(\.0.superview)
            .startWith(base.superview)
            .removeDuplicates
    }
    
    var isVisible: RxObservable<Bool> {
        methodInvoked(#selector(UIView.didMoveToWindow))
            .withUnretained(base)
            .map(\.0.window.isValid)
            .removeDuplicates
            .observe(on: MainScheduler.instance)
    }
}
