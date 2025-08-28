//
//  ObservableConvertibleTypePlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/19.
//

import RxSwift
import RxCocoa

extension ObservableConvertibleType {
    
    /// 串联Observables
    static func +(lhs: Self, rhs: any ObservableConvertibleType) -> Completable {
        lhs.completable + rhs.completable
    }
    
    static var empty: Observable<Element> {
        .empty()
    }
    
    /// 经过一段时间丢弃序列
    /// - Parameter dueTime: 超时时间 | 延迟执行时间
    /// - Parameter scheduler: 计时器运行Scheduler
    /// - Returns: 新事件序列
    func dispose(after dueTime: RxTimeInterval, scheduler: any SchedulerType = MainScheduler.instance) -> Observable<Element> {
        /// 超时定时器
        let timeout = Observable<Int>.timer(dueTime, period: .seconds(1), scheduler: scheduler).take(1)
        /// 返回新的事件序列
        return observable.take(until: timeout)
    }
    
    /// 发生错误时使用应急方案
    /// - Parameter fallback: 应急方案序列
    /// - Returns: 事件序列
    func `catch`<T>(fallback: T) -> Observable<Element> where T: ObservableConvertibleType, T.Element == Element {
        observable.catch { _ in
            fallback.asObservable()
        }
    }
    
    /// Observable 稳定性测试 | 指定时间内是否发出指定个数的事件
    /// - Parameters:
    ///   - timeSpan: 经过的时间 | 默认不检查时间 0 纳秒
    ///   - unStableCount: 最多发出的事件数量 | 默认 1 个
    ///   - scheduler: 运行的Scheduler | 默认留空, 默认创建一个串行队列
    /// - Returns: Observable是否输出稳定的事件序列
    func stabilityCheck(timeSpan: RxTimeInterval = .nanoseconds(0), unStableCount: Int = 1, scheduler: SchedulerType? = nil) -> Observable<Bool> {
        let queueName = "com.check.observable.stable.or.not"
        lazy var defaultScheduler = SerialDispatchQueueScheduler(qos: .default, internalSerialQueueName: queueName)
        return asObservable()
            .window(timeSpan: timeSpan, count: .max, scheduler: scheduler ?? defaultScheduler)
            .flatMapLatest { observable in
                observable.toArray().map(\.count).map { arrayCount in
                    arrayCount < unStableCount
                }
            }
    }
    
    /// 将可观察数组的元素转换为指定的类型
    /// - Parameter type: 指定转换类型
    /// - Returns: 新的数组序列
    func compactConvertTo<T>(_ type: T.Type) -> Observable<[T]> where Self.Element: Sequence  {
        asObservable()
            .compactMap { sequence in
                sequence.compactMap { arrayElement in
                    arrayElement as? T
                }
            }
    }
    
    func concatMapCompletable(_ selector: @escaping (Self.Element) -> Completable) -> Completable {
        asObservable()
            .concatMap(selector)
            .asCompletable()
    }
    
    func flatMapLatest<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        observable.flatMapLatest { _ in source }
    }
    
    var completable: Completable {
        asObservable()
            .ignoreElements()
            .asCompletable()
    }
    
    var once: Observable<Element> {
        observable.take(1)
    }
    
    /// 用于重新订阅事件 | 如: .retry(when: button.rx.tap.triggered)
    /// Tips: 配合.trackError使用的时候, 注意要把.trackError放在.retry(when:)的前面
    var triggered: (Observable<Error>) -> Observable<Element> {
        {
            $0.flatMapLatest { _ in
                asObservable().take(1)
            }
        }
    }
    
    @discardableResult
    func then<Object: AnyObject>(with object: Object, blockByError: Bool = false, _ nextStep: @escaping (Object, Error?) -> Void) -> Disposable {
        asObservable()
            .ignoreElements()
            .asCompletable()
            .subscribe {
                [weak object] event in
                guard let object else { return }
                switch event {
                case .completed:
                    nextStep(object, nil)
                case .error(let error):
                    if !blockByError {
                        nextStep(object, error)
                    }
                }
            }
    }
    
    /// 序列结束时回调Closure
    /// - Parameters:
    ///   - blockByError: 发生Error时是否继续执行下一步
    ///   - nextStep: 下一步执行的Closure
    @discardableResult
    func then(blockByError: Bool = false, _ nextStep: @escaping (Error?) -> Void) -> Disposable {
        asObservable()
            .ignoreElements()
            .asCompletable()
            .subscribe { event in
                switch event {
                case .completed:
                    nextStep(nil)
                case .error(let error):
                    if !blockByError {
                        nextStep(error)
                    }
                }
            }
    }
    
    var observable: Observable<Element> {
        asObservable()
    }
    
    var optionalElement: Observable<Element?> {
        observable.map { $0 }
    }
    
    var anyElement: Observable<Any> {
        observable.map { $0 }
    }
    
    var voidElement: Observable<Void> {
        observable.map { _ in () }
    }
    
    /// 用于蓝牙搜索等长时间操作
    var isProcessing: Driver<Bool> {
        asObservable().materialize()
            .map { event in
                switch event {
                    case .next: return true
                    default: return false
                }
            }
            .startWith(true)
            .removeDuplicates
            .asDriver(onErrorJustReturn: false)
    }
    
    func repeatWhen<O: ObservableType>(_ notifier: O) -> Observable<Element> {
        notifier.map { _ in }
            .startWith(())
            .flatMap { _ -> Observable<Element> in
                self.asObservable()
            }
    }
    
    // MARK: - 生命周期事件发生时将指定参数发送给Observers
    public func on<T, Observer>(_ lifeCycle: RxLifecycleLite, assign designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Observer: ObserverType, Observer.Element == T {
        on(lifeCycle, assign: designated(), to: observers)
    }
    public func on<T, Observer>(_ lifeCycle: RxLifecycleLite, assign designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Observer: ObserverType, Observer.Element == T? {
        on(lifeCycle, assign: designated(), to: observers)
    }
    
    public func on<T, Observers: Sequence>(_ lifeCycle: RxLifecycleLite, assign designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == T {
        
        let designated = designated()
        /// 给observers发送事件
        let send: (T) -> Void = { element in
            observers.forEach { observer in
                observer.onNext(element)
            }
        }
        let onNext: (Element) throws -> Void = { _ in
            guard lifeCycle == .next else { return }
            send(designated)
        }
        let afterNext: (Element) throws -> Void = { _ in
            guard lifeCycle == .afterNext else { return }
            send(designated)
        }
        let onError: (Error) throws -> Void = { _ in
            guard lifeCycle == .error else { return }
            send(designated)
        }
        let afterError: (Error) throws -> Void = { _ in
            guard lifeCycle == .afterError else { return }
            send(designated)
        }
        let onCompleted: () throws -> Void = {
            guard lifeCycle == .completed else { return }
            send(designated)
        }
        let afterCompleted: () throws -> Void = {
            guard lifeCycle == .afterCompleted else { return }
            send(designated)
        }
        let onSubscribe: () -> Void = {
            guard lifeCycle == .subscribe else { return }
            send(designated)
        }
        let onSubscribed: () -> Void = {
            guard lifeCycle == .subscribed else { return }
            send(designated)
        }
        let onDispose: () -> Void = {
            guard lifeCycle == .dispose else { return }
            send(designated)
        }
        return observable.do(onNext: onNext, afterNext: afterNext, onError: onError, afterError: afterError, onCompleted: onCompleted, afterCompleted: afterCompleted, onSubscribe: onSubscribe, onSubscribed: onSubscribed, onDispose: onDispose)
    }
    public func on<T, Observers: Sequence>(_ lifeCycle: RxLifecycleLite, assign designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == T? {
        
        let designated = designated()
        /// 给observers发送事件
        let send: (T?) -> Void = { element in
            observers.forEach { observer in
                observer.onNext(element)
            }
        }
        let onNext: (Element) throws -> Void = { _ in
            guard lifeCycle == .next else { return }
            send(designated)
        }
        let afterNext: (Element) throws -> Void = { _ in
            guard lifeCycle == .afterNext else { return }
            send(designated)
        }
        let onError: (Error) throws -> Void = { _ in
            guard lifeCycle == .error else { return }
            send(designated)
        }
        let afterError: (Error) throws -> Void = { _ in
            guard lifeCycle == .afterError else { return }
            send(designated)
        }
        let onCompleted: () throws -> Void = {
            guard lifeCycle == .completed else { return }
            send(designated)
        }
        let afterCompleted: () throws -> Void = {
            guard lifeCycle == .afterCompleted else { return }
            send(designated)
        }
        let onSubscribe: () -> Void = {
            guard lifeCycle == .subscribe else { return }
            send(designated)
        }
        let onSubscribed: () -> Void = {
            guard lifeCycle == .subscribed else { return }
            send(designated)
        }
        let onDispose: () -> Void = {
            guard lifeCycle == .dispose else { return }
            send(designated)
        }
        return observable.do(onNext: onNext, afterNext: afterNext, onError: onError, afterError: afterError, onCompleted: onCompleted, afterCompleted: afterCompleted, onSubscribe: onSubscribe, onSubscribed: onSubscribed, onDispose: onDispose)
    }
    
    // MARK: - 指定事件(EventLite)发生时将指定参数发送给Observers
    public func on<T, Observer: ObserverType>(event: EventLite, assign designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Observer.Element == T {
        on(event: event, assign: designated(), to: observers)
    }
    public func on<T, Observer: ObserverType>(event: EventLite, assign designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Observer.Element == T? {
        on(event: event, assign: designated(), to: observers)
    }
    public func on<T, Observers: Sequence>(event: EventLite, assign designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == T {
        let designated = designated()
        let onNextEvent: (Event<Self.Element>) throws -> Void = { rxEvent in
            /// 给observers发送事件
            let send: (T) -> Void = { element in
                observers.forEach { observer in
                    observer.onNext(element)
                }
            }
            /// 事件匹配
            switch (event, rxEvent) {
            case (.next, .next):
                send(designated)
            case (.completed, .completed):
                send(designated)
            case (.error, .error):
                send(designated)
            default:
                break
            }
        }
        return observable
            .materialize()
            .do(onNext: onNextEvent)
            .dematerialize()
    }
    public func on<T, Observers: Sequence>(event: EventLite, assign designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == T? {
        let designated = designated()
        let onNextEvent: (Event<Self.Element>) throws -> Void = { rxEvent in
            /// 给observers发送事件
            let send: (T?) -> Void = { element in
                observers.forEach { observer in
                    observer.onNext(element)
                }
            }
            /// 事件匹配
            switch (event, rxEvent) {
            case (.next, .next):
                send(designated)
            case (.completed, .completed):
                send(designated)
            case (.error, .error):
                send(designated)
            default:
                break
            }
        }
        return observable
            .materialize()
            .do(onNext: onNextEvent)
            .dematerialize()
    }
    
    // MARK: - 指定事件发生时将指定参数发送给Observers | 只匹配.next和.completed事件(参见RxSwift.Event的Equatable协议实现)
    public func on<T, Observer: ObserverType>(event: Event<Element>, assign designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Element: Equatable, Observer.Element == T {
        on(event: event, assign: designated(), to: observers)
    }
    public func on<T, Observer: ObserverType>(event: Event<Element>, assign designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Element: Equatable, Observer.Element == T? {
        on(event: event, assign: designated(), to: observers)
    }
    public func on<T, Observers: Sequence>(event: Event<Element>, assign designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Element: Equatable, Observers.Element.Element == T {
        let designated = designated()
        let nextEvent: (Event<Element>) throws -> Void = { rxEvent in
            if event == rxEvent {
                observers.forEach { observer in
                    observer.onNext(designated)
                }
            }
        }
        return observable
            .materialize()
            .do(onNext: nextEvent)
            .dematerialize()
    }
    public func on<T, Observers: Sequence>(event: Event<Element>, assign designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Element: Equatable, Observers.Element.Element == T? {
        let designated = designated()
        let nextEvent: (Event<Element>) throws -> Void = { rxEvent in
            if event == rxEvent {
                observers.forEach { observer in
                    observer.onNext(designated)
                }
            }
        }
        return observable
            .materialize()
            .do(onNext: nextEvent)
            .dematerialize()
    }
    
    // MARK: - 将固定的元素发送给指定的Observers
    public func assign<T, Observer: ObserverType>(_ designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Observer.Element == T {
        assign(designated(), to: observers)
    }
    public func assign<T, Observer: ObserverType>(_ designated: @escaping @autoclosure () -> T, to observers: Observer...) -> Observable<Element> where Observer.Element == T? {
        assign(designated(), to: observers)
    }
    public func assign<T, Observers: Sequence>(_ designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == T {
        let designated = designated()
        let onNext: (Element) throws -> Void = { _ in
            observers.forEach { observer in
                observer.onNext(designated)
            }
        }
        return observable.do(onNext: onNext)
    }
    public func assign<T, Observers: Sequence>(_ designated: @escaping @autoclosure () -> T, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == T? {
        let designated = designated()
        let onNext: (Element) throws -> Void = { _ in
            observers.forEach { observer in
                observer.onNext(designated)
            }
        }
        return observable.do(onNext: onNext)
    }
    
    // MARK: - 将转换后的元素发送给指定的Observers | 返回原序列
    public func assign<Transformed, Observer: ObserverType>(_ transform: @escaping (Element) throws -> Transformed, to observers: Observer...) -> Observable<Element> where Observer.Element == Transformed {
        assign(transform, to: observers)
    }
    public func assign<Transformed, Observer: ObserverType>(_ transform: @escaping (Element) throws -> Transformed, to observers: Observer...) -> Observable<Element> where Observer.Element == Transformed? {
        assign(transform, to: observers)
    }
    public func assign<Transformed, Observers: Sequence>(_ transform: @escaping (Element) throws -> Transformed, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == Transformed {
        let onNext: (Element) throws -> Void = { element in
            let transformed = try transform(element)
            observers.forEach { observer in
                observer.onNext(transformed)
            }
        }
        return observable.do(onNext: onNext)
    }
    public func assign<Transformed, Observers: Sequence>(_ transform: @escaping (Element) throws -> Transformed, to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == Transformed? {
        let onNext: (Element) throws -> Void = { element in
            let transformed = try transform(element)
            observers.forEach { observer in
                observer.onNext(transformed)
            }
        }
        return observable.do(onNext: onNext)
    }
    
    // MARK: - 将元素发送给指定的Observers
    /// 利用旁路特性为观察者赋值
    /// - Parameter observers: 观察者类型
    /// - Returns: Observable<Element>
    public func assign<Observer>(to observers: Observer...) -> Observable<Element> where Observer: ObserverType, Observer.Element == Element {
        assign(to: observers)
    }
    
    /// 利用旁路特性为观察者赋值
    /// - Parameter observers: 观察者类型
    /// - Returns: Observable<Element?>
    public func assign<Observer>(to observers: Observer...) -> Observable<Element> where Observer: ObserverType, Observer.Element == Element? {
        assign(to: observers)
    }
    
    /// 利用旁路特性为观察者赋值
    /// - Parameter observers: 观察者类型
    /// - Returns: Observable<Element>
    public func assign<Observers: Sequence>(to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == Element {
        let onNext: (Element) -> Void = { element in
            observers.forEach { observer in
                observer.onNext(element)
            }
        }
        return observable.do(onNext: onNext)
    }
    
    /// 利用旁路特性为观察者赋值
    /// - Parameter observers: 观察者类型
    /// - Returns: Observable<Element?>
    public func assign<Observers: Sequence>(to observers: Observers) -> Observable<Element> where Observers.Element: ObserverType, Observers.Element.Element == Element? {
        let onNext: (Element) -> Void = { element in
            observers.forEach { observer in
                observer.onNext(element)
            }
        }
        return observable.do(onNext: onNext)
    }
}

extension ObservableConvertibleType where Element: Equatable {
    
    func isEqualOriginValue() -> Observable<(value: Element, isEqualOriginValue: Bool)> {
        asObservable()
            .scan(nil) { acum, x -> (origin: Element, current: Element)? in
                if let acum = acum {
                    return (origin: acum.origin, current: x)
                } else {
                    return (origin: x, current: x)
                }
            }
            .map {
                ($0!.current, isEqualOriginValue: $0!.origin == $0!.current)
            }
    }
}

// MARK: - Observable of Collection
extension ObservableConvertibleType where Element: Collection {
    
    func removeDuplicates<Value>(at keyPath: KeyPath<Element.Element, Value>) -> Observable<[Element.Element]> where Value: Equatable {
        asObservable().map { collection in
            collection.removingDuplicates(at: keyPath)
        }
    }
    
    var isEmpty: Observable<Bool> {
        observable.map(\.isEmpty)
    }
    
    var isNotEmpty: Observable<Bool> {
        observable.map(\.isNotEmpty)
    }
    
    /// Emit filled elements only.
    var filled: Observable<Element> {
        asObservable().compactMap(\.filledOrNil)
    }
    
    /// Emit nil if the collection is empty.
    var filledOrNil: Observable<Element?> {
        asObservable().map(\.filledOrNil)
    }
}

// MARK: - Observable of OptionalConvertible
extension ObservableConvertibleType where Element: OptionalConvertible {
    
    /// 将元素转换为指定的类型,如果转换失败则使用备选值
    func or<Result>(_ fallback: Result, transform: @escaping (Element.Wrapped) throws -> Result) -> Observable<Result> {
        asObservable()
            .map { element in
                try element.optionalValue.or(fallback, map: transform)
            }
    }
    
    /// 元素如果为空则使用备选值
    func or(_ fallback: Element.Wrapped) -> Observable<Element.Wrapped> {
        asObservable()
            .map { element in
                element.optionalValue.or(fallback)
            }
    }
    
    var unwrapped: Observable<Element.Wrapped> {
        asObservable().compactMap(\.optionalValue)
    }
}

extension ObservableConvertibleType where Element == String? {
    var orEmpty: Observable<String> {
        asObservable()
            .map(\.orEmpty)
    }
    func mapValidString(or defaultValue: String) -> Observable<String> {
        asObservable()
            .map { element in
                element.unwrappedValidStringOr(defaultValue)
            }
    }
}

extension ObservableConvertibleType where Element == Int {
    
    var isNotEmpty: Observable<Bool> {
        isEmpty.map { isEmpty in !isEmpty }
    }
    
    var isEmpty: Observable<Bool> {
        asObservable()
            .map { $0 <= 0 }
    }
}

extension ObservableConvertibleType where Element: Equatable {
    /// 忽略重复的元素
    var removeDuplicates: Observable<Element> {
        asObservable()
            .distinctUntilChanged()
    }
}
