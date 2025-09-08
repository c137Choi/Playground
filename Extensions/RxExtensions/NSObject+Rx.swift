//
//  NSObject+Rx.swift
//
//  Created by Choi on 2022/8/4.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectiveC

enum Rx {
    @UniqueAddress static var disposeBag
    @UniqueAddress static var cancellableBag
    @UniqueAddress static var activityTrackingDisposeBag
    @UniqueAddress static var anyUpdateRelay
}

public extension Reactive where Base: AnyObject {
    
    /// 更新数据流(跳过初始值) | 内部使用了.take(until: deallocated)
    var anyNewUpdate: Observable<Any> {
        anyUpdate.skip(1)
    }
    
    /// 更新数据流(包括初始值) | 内部使用了.take(until: deallocated)
    private var anyUpdate: Observable<Any> {
        anyUpdateRelay.take(until: deallocated)
    }
    
    /// 通用的任意类型数据更新的BehaviorRelay | 初始值为()/Void
    var anyUpdateRelay: BehaviorRelay<Any> {
        synchronized(lock: base) {
            guard let existingRelay = associated(BehaviorRelay<Any>.self, base, Rx.anyUpdateRelay) else {
                /// 创建Relay | 起始值为Void
                let newRelay = BehaviorRelay<Any>(value: ())
                setAssociatedObject(base, Rx.anyUpdateRelay, newRelay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newRelay
            }
            return existingRelay
        }
    }
    
    /// a unique DisposeBag that is related to the Reactive.Base instance only for Reference type
    var disposeBag: DisposeBag {
        get {
            synchronized(lock: base) {
                guard let existingBag = associated(DisposeBag.self, base, Rx.disposeBag) else {
                    let newBag = DisposeBag()
                    setAssociatedObject(base, Rx.disposeBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return newBag
                }
                return existingBag
            }
        }
        
        nonmutating set(newBag) {
            synchronized(lock: base) {
                setAssociatedObject(base, Rx.disposeBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// 供Combine框架使用的CancellableBag
    var cancellableBag: CancellableBag {
        get {
            synchronized(lock: base) {
                guard let existingBag = associated(CancellableBag.self, base, Rx.cancellableBag) else {
                    let newBag = CancellableBag()
                    setAssociatedObject(base, Rx.cancellableBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return newBag
                }
                return existingBag
            }
        }
        
        nonmutating set(newBag) {
            synchronized(lock: base) {
                setAssociatedObject(base, Rx.cancellableBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var activityTrackingDisposebag: DisposeBag {
        get {
            synchronized(lock: base) {
                guard let existingBag = associated(DisposeBag.self, base, Rx.activityTrackingDisposeBag) else {
                    let newBag = DisposeBag()
                    setAssociatedObject(base, Rx.activityTrackingDisposeBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return newBag
                }
                return existingBag
            }
        }
        
        nonmutating set(newBag) {
            synchronized(lock: base) {
                setAssociatedObject(base, Rx.activityTrackingDisposeBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// disposeBag置空 | 清空之前所有的订阅
    func clearDisposeBag() {
        disposeBag = DisposeBag()
    }
}

// MARK: - Trackers Protocol
protocol ProgressTrackable {
    var progress: Double { get }
}

protocol ProgressTracker: AnyObject {
    /// 如果progress为空, 则表示未完成
    func trackProgress(_ progress: Double?)
}

protocol ErrorTracker: UIResponder {
    func trackError(_ error: Error?, isFatal: Bool)
}

protocol ActivityTracker: NSObject {
    func trackActivity(_ isProcessing: Bool)
}

extension Reactive where Base: ActivityTracker {
    
    var activity: ActivityIndicator {
        activity(delayed: .seconds(0))
    }
    
    /// 延迟跟踪的ActivityIndicator
    /// - Parameter timeInterval: 延迟多长时间开始追踪
    func activity(delayed timeInterval: RxTimeInterval) -> ActivityIndicator {
        synchronized(lock: base) {
            /// 创建活动指示器
            let indicator = ActivityIndicator(delayed: timeInterval)
            /// 每次都重新跟踪活动序列
            activityTrackingDisposebag = DisposeBag {
                indicator.drive(with: base) { weakBase, processing in
                    weakBase.trackActivity(processing)
                }
            }
            return indicator
        }
    }
}

extension Reactive where Base: ErrorTracker {
    
    var errorConsumer: Binder<Error?> {
        Binder(base) { weakBase, error in
            weakBase.trackError(error, isFatal: false)
        }
    }
    
    var fatalErrorConsumer: Binder<Error?> {
        Binder(base) { weakBase, error in
            weakBase.trackError(error, isFatal: true)
        }
    }
}

// MARK: - 扩展事件类型为<#EventConvertible#>的事件序列
extension ObservableConvertibleType where Element: EventConvertible {
    
    /// 跟踪错误事件
    /// - Parameters:
    ///   - tracker: 错误跟踪者
    ///   - respondDepth: 响应深度 | nextResponder的深度, 如UIView的父视图
    /// - Returns: 观察序列
    func trackErrorEvent(_ tracker: ErrorTracker?, respondDepth: Int = 0) -> Observable<Event<Element.Element>> {
        asObservable()
            .dematerialize()
            .trackError(tracker, respondDepth: respondDepth)
            .materialize()
    }
}

extension ObservableConvertibleType {
    
    /// 跟踪错误
    /// - Parameters:
    ///   - tracker: 错误跟踪者
    ///   - respondDepth: 响应深度 | nextResponder的深度, 如UIView的父视图
    /// - Returns: 观察序列
    func trackError(_ tracker: ErrorTracker?, isFatal: Bool = true, respondDepth: Int = 0) -> Observable<Element> {
        observable.do { _ in
            
        } onError: {
            [weak tracker] error in
            /// 初值设置为tracker
            var responder = tracker
            /// 确保传入参数(响应深度)合法
            guard respondDepth >= 0 else {
                responder?.trackError(error, isFatal: isFatal)
                return
            }
            for _ in 0 ..< respondDepth {
                if let nextTracker = responder.flatMap(\.next) as? ErrorTracker {
                    responder = nextTracker
                }
            }
            responder?.trackError(error, isFatal: isFatal)
        }
    }
}

extension ObservableConvertibleType where Element: ProgressTrackable {
    
    func trackProgress(_ tracker: any ProgressTracker) -> Observable<Element> {
        observable.do {
            [weak tracker] element in
            tracker?.trackProgress(element.progress)
        } onError: {
            [weak tracker] _ in
            tracker?.trackProgress(.none)
        } onCompleted: {
            [weak tracker] in
            tracker?.trackProgress(1.0)
        }
    }
}
