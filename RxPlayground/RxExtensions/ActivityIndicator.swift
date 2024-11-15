//
//  ActivityIndicator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        _source
    }
}

/**
Enables monitoring of sequence computation.

If there is at least one sequence computation in progress, `true` will be sent.
When all activities complete `false` will be sent.
*/
public class ActivityIndicator : SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let subscriptionDelay: RxTimeInterval
    private let recursiveLock = NSRecursiveLock()
    private let relay = BehaviorRelay(value: 0)
    private let isLoading: SharedSequence<SharingStrategy, Bool>

    public init(delayed subscriptionDelay: RxTimeInterval = 0, isProcessing: Bool = false) {
        self.subscriptionDelay = subscriptionDelay
        self.isLoading = relay
            .map(\.isPositive)
            .removeDuplicates
            .asDriver(onErrorJustReturn: false)
        if isProcessing {
            increment(1)
        }
    }
    
    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        Observable.using {
            self.increment()
            return ActivityToken(source: source.observable, disposeAction: self.decrement)
        } observableFactory: { token in
            token.observable
        }
    }

    private func increment(_ value: Int = 1) {
        recursiveLock.lock()
        relay.accept(relay.value + value)
        recursiveLock.unlock()
    }

    private func decrement() {
        recursiveLock.lock()
        relay.accept(relay.value - 1)
        recursiveLock.unlock()
    }
    
    public func reset() {
        recursiveLock.lock()
        relay.accept(0)
        recursiveLock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        isLoading.observable
            .delaySubscription(subscriptionDelay, scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: false)
    }
}

extension ActivityIndicator {
    
    /// 只追踪前几个元素
    /// - Parameters:
    ///   - elementCount: 追踪的元素个数
    ///   - source: 信号源
    /// - Returns: Observable
    fileprivate func trackActivity<Source: ObservableConvertibleType>(first elementCount: Int, of source: Source) -> Observable<Source.Element> {
        let afterNext: (Source.Element) -> Void = { _ in
            self.decrement()
        }
        return Observable.using { () -> ActivityToken<Source.Element> in
            self.increment(elementCount)
            return ActivityToken(source: source.observable, disposeAction: self.decrement)
        } observableFactory: { token in
            token.observable.do(afterNext: afterNext)
        }
    }
}

extension ObservableConvertibleType {
    
    public func trackActivity(first elementCount: Int, _ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivity(first: elementCount, of: self)
    }
    
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }
}
extension Completable {
    
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Completable {
        activityIndicator.trackActivityOfObservable(self).asCompletable()
    }
}
