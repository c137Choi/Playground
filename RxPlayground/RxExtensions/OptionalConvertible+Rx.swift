//
//  OptionalConvertible+Rx.swift
//  KnowLED
//
//  Created by Choi on 2024/5/16.
//

import Foundation
import RxSwift
import RxCocoa

/// 几个为Binder赋值的方法 | 赋值后返回自身, 方便后续串行赋值
extension OptionalConvertible {
    
    @discardableResult
    func assign<Observer: ObserverType>(skipVoid: Bool = false, to observers: Observer...) -> Self where Observer.Element == Wrapped? {
        assign(skipVoid: skipVoid, to: observers)
    }
    
    @discardableResult
    func assign<Observer: ObserverType>(skipVoid: Bool = false, to observers: [Observer]) -> Self where Observer.Element == Wrapped? {
        if skipVoid, optionalValue.isVoid {
            return self
        }
        observers.forEach { observer in
            observer.onNext(optionalValue)
        }
        return self
    }
    
    @discardableResult
    func assign<Observer: ObserverType>(to observers: Observer...) -> Self where Observer.Element == Wrapped {
        assign(to: observers)
    }
    
    @discardableResult
    func assign<Observer: ObserverType>(to observers: [Observer]) -> Self where Observer.Element == Wrapped {
        guard let unwrapped = optionalValue else { return self }
        observers.forEach { observer in
            observer.onNext(unwrapped)
        }
        return self
    }
}

// MARK: - Reactive<OptionalConvertible>
// 任意NSObject及其子类都可以用NSObject().rx.assign(to: Observer...)的方式给Observer赋值
extension Reactive where Base: OptionalConvertible {
    
    @discardableResult func assign<Observer: ObserverType>(to observers: Observer...) -> Base where Observer.Element == Base? {
        assign(to: observers)
    }
    @discardableResult func assign<Observer: ObserverType>(to observers: [Observer]) -> Base where Observer.Element == Base? {
        /// 依次通知Observer
        observers.forEach { observer in
            observer.onNext(base)
        }
        return base
    }
    
    
    @discardableResult func assign<Observer: ObserverType>(to observers: Observer...) -> Base where Observer.Element == Base {
        assign(to: observers)
    }
    @discardableResult func assign<Observer: ObserverType>(to observers: [Observer]) -> Base where Observer.Element == Base {
        /// 依次通知Observer
        observers.forEach { observer in
            observer.onNext(base)
        }
        return base
    }
}
