//
//  RxPlus.swift
//  RxPlayground
//
//  Created by Choi on 2021/4/16.
//

import RxSwift
import RxCocoa
import Combine

/// Rx序列生命周期(简化版)
public enum RxLifecycleLite {
    case next
    case afterNext
    case error
    case afterError
    case completed
    case afterCompleted
    case subscribe
    case subscribed
    case dispose
}

///// Rx序列生命周期(暂未启用)
//public enum RxLifecycle<Element> {
//    case next(Element)
//    case afterNext(Element)
//    case error(Swift.Error)
//    case afterError(Swift.Error)
//    case completed
//    case afterCompleted
//    case subscribe
//    case subscribed
//    case dispose
//}

/// RxSwift.Event<Element>类型的简化版
@frozen public enum EventLite {
    case next
    case error
    case completed
}

/// 扩展RxSwift.Event遵循Equatable协议 | 其Element同时必须是Equatable
extension RxSwift.Event: @retroactive Equatable where Element: Equatable {
    
    /// 只对比.next和.completed事件, 因为Error协议无法对比, 故其他情况一律返回false
    public static func == (lhs: RxSwift.Event<Element>, rhs: RxSwift.Event<Element>) -> Bool {
        switch (lhs, rhs) {
        case (.next(let leftElement), .next(let rightElement)):
            return leftElement == rightElement
        case (.completed, .completed):
            return true
        default:
            return false
        }
    }
}

extension DisposeBag {
    
    static var empty: DisposeBag {
        DisposeBag()
    }
    
    func insert(@ArrayBuilder<Disposable> builder: () -> [Disposable]) {
        let disposables = builder()
        insert(disposables)
    }
    
    public convenience init(@ArrayBuilder<Disposable> builder: () -> [Disposable]) {
        let disposables = builder()
        self.init(disposing: disposables)
    }
}

@propertyWrapper
class Variable<Wrapped>: ObservableType {
    /// ObservableConvertibleType序列元素
    typealias Element = Wrapped
    /// 核心Relay对象
    let relay: BehaviorRelay<Wrapped>
    /// 数据访问锁
    private lazy var dataAccessLock = NSLock()
    /// 设置为true,则订阅的conditionalValue事件序列不发送事件
    private var blockEvents = false
    /// 数据访问是否加锁
    private let withAccessLock: Bool
    /// 有条件的事件序列 | blockEvents为true时不发送事件
    /// 常用于控件之间的双向绑定
    /// 配合setValue(:sendEvent:)方法使用
    var conditionalValue: Observable<Wrapped> {
        relay.withUnretained(self).compactMap { weakSelf, element in
            /// 始终取消阻断事件
            defer {
                weakSelf.blockEvents = false
            }
            /// 如果阻断事件则返回空(不发送事件)
            if weakSelf.blockEvents {
                return nil
            } else {
                return element
            }
        }
    }
    
    /// 更新值
    /// - Parameters:
    ///   - newValue: 新值
    ///   - sendEvent: 是否发送事件 | 外部需要订阅conditionalValue
    func setValue(_ newValue: Wrapped, sendEvent: Bool) {
        /// 设置是否阻断事件发送 | 在上面的conditionalValue属性中设置取消事件阻断
        blockEvents = !sendEvent
        /// 设置值, 外部如果订阅的话会收到通知
        wrappedValue = newValue
    }
    
    var projectedValue: Variable<Wrapped> {
        self
    }
    
    /// 初始化
    /// - Parameters:
    ///   - wrappedValue: 初始值
    ///   - withAccessLock: 数据访问是否加锁
    init(wrappedValue: Wrapped, withAccessLock: Bool = false) {
        self.relay = BehaviorRelay(value: wrappedValue)
        self.withAccessLock = withAccessLock
    }
    
    var wrappedValue: Wrapped {
        get {
            if withAccessLock {
                return dataAccessLock.withLock {
                    relay.value
                }
            } else {
                return relay.value
            }
        }
        set {
            if withAccessLock {
                dataAccessLock.withLock {
                    relay << newValue
                }
            } else {
                relay << newValue
            }
        }
    }
    
    var skipFirst: Observable<Wrapped> {
        relay.skip(1)
    }
    
    func asObservable() -> RxSwift.Observable<Wrapped> {
        relay.asObservable()
    }
    
    func subscribe<Observer>(_ observer: Observer) -> any Disposable where Observer: ObserverType, Observer.Element == Wrapped {
        asObservable().subscribe(observer)
    }
}

@propertyWrapper
final class ClamppedVariable<T>: Variable<T> where T: Comparable {
    
    let range: ClosedRange<T>
    
    init(wrappedValue: T, range: ClosedRange<T>) {
        self.range = range
        let initialValue = range << wrappedValue
        super.init(wrappedValue: initialValue)
    }
    
    /// 这里重写此属性是必须的,否则无法使用$property语法.relay
    override var projectedValue: ClamppedVariable<T> {
        self
    }
    
    override var wrappedValue: T {
        get { super.wrappedValue }
        set { super.wrappedValue = range << newValue }
    }
    
    var upperBound: T {
        range.upperBound
    }
    
    var lowerBound: T {
        range.lowerBound
    }
}

@propertyWrapper
final class CycledCase<Case: Equatable>: Variable<Case> {
    typealias CaseArray = [Case]
    /// 元素数组
    let cases: CaseArray
    /// 当前索引
    private var currentIndex: CaseArray.Index
    /// 初始化方法
    init(wrappedValue: Case, cases: CaseArray) {
        /// 初始元素必须包含在数组内 | 同时保证数组为空的情况初始化失败
        guard let currentIndex = cases.firstIndex(of: wrappedValue) else {
            fatalError("元素不在数组内或循环数组为空")
        }
        /// 初始化数组
        self.cases = cases
        /// 储存当前索引
        self.currentIndex = currentIndex
        /// 调用父类初始化方法
        super.init(wrappedValue: wrappedValue)
    }
    
    override var projectedValue: CycledCase<Case> {
        self
    }
    
    override var wrappedValue: Case {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }
    
    /// 下一个元素
    private func nextCase() {
        let nextIndex = currentIndex + 1
        guard let cycledIndex = cases.indices[cycledIndex: nextIndex] else { return }
        wrappedValue = cases[cycledIndex]
        currentIndex = cycledIndex
    }
    
    /// 上一个元素
    private func lastCase() {
        let nextIndex = currentIndex - 1
        guard let cycledIndex = cases.indices[cycledIndex: nextIndex] else { return }
        wrappedValue = cases[cycledIndex]
        currentIndex = cycledIndex
    }
    
    static postfix func ++(cycledCase: CycledCase) {
        cycledCase.nextCase()
    }
    
    static postfix func --(cycledCase: CycledCase) {
        cycledCase.lastCase()
    }
}

@propertyWrapper
final class CycledVariable<T>: Variable<T> where T: Comparable {
    /// 范围
    let range: ClosedRange<T>
    /// 用于发送范围错误事件
    private let rangeBoundErrorSubject = PublishSubject<RangeBoundError>()
    /// 初始化方法
    init(wrappedValue: T, range: ClosedRange<T>) {
        self.range = range
        let initialValue = range << wrappedValue
        super.init(wrappedValue: initialValue)
    }
    
    override var projectedValue: CycledVariable<T> {
        self
    }
    
    override var wrappedValue: T {
        get { super.wrappedValue }
        set {
            do throws(RangeBoundError) {
                super.wrappedValue = try range.constrainedResult(newValue).get()
            } catch {
                switch error {
                case .tooLow:
                    self.rangeBoundErrorSubject.onNext(.tooLow)
                    super.wrappedValue = range.upperBound
                case .tooHigh:
                    self.rangeBoundErrorSubject.onNext(.tooHigh)
                    super.wrappedValue = range.lowerBound
                }
            }
        }
    }
    
    var rangeBoundError: Observable<RangeBoundError> {
        rangeBoundErrorSubject.observable
    }
}

@propertyWrapper
struct WeakVariable<Wrapped: AnyObject>: ObservableType {
    /// ObservableConvertibleType序列元素
    typealias Element = Wrapped?
    /// 弱引用
    private weak var weakReference: Wrapped?
    /// 发布者
    private let subject = PublishSubject<Wrapped?>()
    
    var wrappedValue: Wrapped? {
        get { weakReference }
        set { weakReference = newValue
            subject.onNext(newValue)
        }
    }
    
    init(wrappedValue: Wrapped?) {
        self.weakReference = wrappedValue
    }
    
    func asObservable() -> RxSwift.Observable<Wrapped?> {
        subject.startWith(weakReference)
    }
    
    func subscribe<Observer>(_ observer: Observer) -> any Disposable where Observer : ObserverType, Observer.Element == Wrapped? {
        asObservable().subscribe(observer)
    }
}

extension ObservableType {
    
    /// 映射成指定的值
    /// - Parameter designated: 生成元素的自动闭包
    /// - Returns: Observable<T>
    public func mapDesignated<T>(_ designated: @escaping @autoclosure () -> T) -> Observable<T> {
        map { _ in designated() }
    }
    
    var shortHistory: Observable<ShortHistory<Element>> {
        lastAndLatest.map(ShortHistory.init)
    }
    
    /// 获取上一个元素 和 当前元素
    var lastAndLatest: Observable<(Element?, Element)> {
        scan(Array<Element>.empty) { history, next in
            history.appending(next).suffix(2)
        }
        .map { lastTwo in
            guard let last = lastTwo.last else {
                throw "元素数量非法, 检查.scan操作符内的逻辑"
            }
            return lastTwo.count == 1 ? (nil, last) : (lastTwo.first, last)
        }
    }
    
    /// 订阅完成事件
    ///   - object: 弱引用对象
    /// - Parameter completed: 完成回调
    /// - Returns: Disposable
    public func subscribeCompletedEvent<Object: AnyObject>(
        with object: Object,
        _ completed: @escaping (Object) -> Void)
    -> Disposable {
        subscribe(with: object, onCompleted: completed)
    }
    
    /// 订阅完成事件
    /// - Parameter completed: 完成回调
    /// - Returns: Disposable
    public func subscribeCompletedEvent(_ completed: @escaping SimpleCallback) -> Disposable {
        subscribe(onCompleted: completed)
    }
    
    
    /// onNext事件触发执行一个简单回调
    /// - Parameter execute: 回调方法
    /// - Returns: Disposable
    public func trigger(_ execute: @escaping SimpleCallback) -> Disposable {
        subscribe { _ in
            execute()
        } onError: { error in
            dprint("Trigger ignored error: \(error)")
        }
    }
    
    /// 绑定忽略Error事件的序列
    /// 错误事件由上层调用.trackError(ErrorTracker)处理错误
    /// - Parameter observers: 观察者们
    /// - Returns: Disposable
    public func bindErrorIgnored<Observer: ObserverType>(to observers: Observer...) -> Disposable where Observer.Element == Element {
        subscribe { nextElement in
            observers.forEach { observer in
                observer.onNext(nextElement)
            }
        } onError: { error in
            dprint("Bind ignored error: \(error)")
        }
    }

    /// 绑定忽略Error事件的序列
    /// 错误事件由上层调用.trackError(ErrorTracker)处理错误
    /// - Parameter observers: 观察者们
    /// - Returns: Disposable
    public func bindErrorIgnored<Observer: ObserverType>(to observers: Observer...) -> Disposable where Observer.Element == Element? {
        asOptional(Element.self).subscribe { nextElement in
            observers.forEach { observer in
                observer.onNext(nextElement)
            }
        } onError: { error in
            dprint("Bind ignored error: \(error)")
        }
    }
    
    /// 绑定忽略Error事件的序列
    /// - Parameters:
    ///   - object: 弱引用的对象
    ///   - onNext: Next事件
    /// - Returns: Disposable
    public func bindErrorIgnored<Object: AnyObject>(with object: Object, onNext: @escaping (Object, Element) -> Void) -> Disposable {
        subscribe {
            [weak object] nextElement in
            guard let object else { return }
            onNext(object, nextElement)
        } onError: { error in
            dprint("Bind ignored error: \(error)")
        }
    }
    
    /// 绑定忽略Error事件的序列
    /// - Parameter onNext: Next事件
    /// - Returns: Disposable
    public func bindErrorIgnored(onNext: @escaping (Element) -> Void) -> Disposable {
        subscribe(onNext: onNext) { error in
            dprint("Bind ignored error: \(error)")
        }
    }
}

extension ObservableConvertibleType {
    
    
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
    
    func flatMap<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        asObservable()
            .flatMap { _ in source }
    }
    
    func flatMapLatest<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        asObservable()
            .flatMapLatest { _ in source }
    }
    
    var completed: Completable {
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
        asObservable()
            .map { $0 }
    }
    
    var anyElement: Observable<Any> {
        asObservable()
            .map { $0 }
    }
    
    var voidElement: Observable<Void> {
        asObservable()
            .map { _ in () }
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

extension ObservableType {
    
    /// 转换成指定的类型 | 转换失败则不发送事件
    /// - Parameter type: 转换的类型
    /// - Returns: Observable
    func compactMap<T>(_ type: T.Type) -> Observable<T> {
        compactMap { element in
            element as? T
        }
    }
    
    /// 转换成指定的类型 | 转换失败后返回默认值
    /// - Parameters:
    ///   - type: 转换的类型
    ///   - defaultValue: 转换失败返回的默认值
    /// - Returns: Observable
    public func `as`<T>(_ type: T.Type, or defaultValue: T) -> Observable<T> {
        asOptional(type).map { maybeT in
            maybeT.or(defaultValue)
        }
    }
    
    /// 转换成Optional<T>
    /// - Parameter type: 转换的类型
    /// - Returns: Observable
    func asOptional<T>(_ type: T.Type) -> Observable<T?> {
        map { element in element as? T }
    }
    
    /// 转换成指定类型 | 如果转换失败则序列抛出错误
    /// - Parameter type: 转换的类型
    /// - Returns: Observable
    func `as`<T>(_ type: T.Type) -> Observable<T> {
        map { element in
            if let valid = element as? T {
                return valid
            }
            throw "类型转换失败"
        }
    }
    
    public func bindTo<Observer: ObserverType>(@ArrayBuilder<Observer> observersBuilder: () -> Array<Observer>) -> Disposable where Observer.Element == Element {
        let observers = observersBuilder()
        return bind(to: observers)
    }
    
    public func bindTo<Observer: ObserverType>(@ArrayBuilder<Observer> observersBuilder: () -> Array<Observer>) -> Disposable where Observer.Element == Element? {
        let observers = observersBuilder()
        return bind(to: observers)
    }
    
    public func bind<Observer: ObserverType>(to observers: Array<Observer>) -> Disposable where Observer.Element == Element {
        subscribe { event in
            observers.forEach { observer in
                observer.on(event)
            }
        }
    }
    
    public func bind<Observer: ObserverType>(to observers: Array<Observer>) -> Disposable where Observer.Element == Element? {
        optionalElement.subscribe { event in
            observers.forEach { observer in
                observer.on(event)
            }
        }
    }
}

extension ObservableType where Element == Bool {
    
    /// 条件成立时发送元素
    var isTrue: Observable<Element> {
        filter(\.isTrue)
    }
    
    /// 条件不成立时发送元素
	var isFalse: Observable<Element> {
        filter(\.isFalse)
	}
}

extension ObservableType where Element: ObservableConvertibleType {
    
    public var switchLatest: Observable<Element.Element> {
        switchLatest()
    }
}

extension Observable {
    
    
    /// 合并Bool序列值 | 任意一个为true时发送true
    public static func eitherSatisfied<T>(_ observables: T...) -> Observable<T.Element> where T: ObservableConvertibleType, T.Element == Bool {
        eitherSatisfied(observables)
    }
    
    /// 合并Bool序列值 | 任意一个为true时发送true
    public static func eitherSatisfied<Collection: Swift.Collection>(_ collection: Collection) -> Observable<Collection.Element.Element> where Collection.Element: ObservableConvertibleType, Collection.Element.Element == Bool {
        Observable<Collection.Element.Element>.combineLatest(collection.map(\.observable)).map { bools in
            bools.set.contains(true)
        }
    }
    
    /// 合并Bool序列值
    /// - Parameter observables: Bool序列可变参数
    /// - Returns: Bool序列(全部满足为true时值为true)
    public static func allSatisfied<T>(_ observables: T...) -> Observable<T.Element> where T: ObservableConvertibleType, T.Element == Bool {
        allSatisfied(observables)
    }
    
    /// 合并Bool序列值 | 全部满足为true时发送true
    public static func allSatisfied<Collection: Swift.Collection>(_ collection: Collection) -> Observable<Collection.Element.Element> where Collection.Element: ObservableConvertibleType, Collection.Element.Element == Bool {
        Observable<Collection.Element.Element>.combineLatest(collection.map(\.observable)).map { bools in
            bools.allSatisfy(\.isTrue)
        }
    }
    
    /// 合并指定的序列数组 | 全部满足为true时发送true
    static func merge<T>(@ArrayBuilder<T> observablesBuilder: () -> [T]) -> Observable<T.Element> where T: ObservableConvertibleType {
        let observables = observablesBuilder()
        return observables.merged
    }
    
    /// 返回amb事件序列: 谁先发送事件就持续监听序列的事件
    /// - Parameter observablesBuilder: 监听序列构建
    /// - Returns: 最终订阅的事件序列
    static func amb<T>(@ArrayBuilder<T> observablesBuilder: () -> [T]) -> Observable<T.Element> where T: ObservableConvertibleType {
        let observables = observablesBuilder().map(\.observable)
        return Observable<T.Element>.amb(observables)
    }
}

extension Observable where Element == Error {
    
    func tryAfter(_ timeInterval: RxTimeInterval, maxRetryCount: Int) -> Observable<Int> {
        enumerated().flatMap { index, error -> Observable<Int> in
            guard index < maxRetryCount else {
                return .error(error).observe(on: MainScheduler.asyncInstance)
            }
            return .just(0).delay(timeInterval, scheduler: MainScheduler.asyncInstance)
        }
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

extension ObservableConvertibleType {
    /// 串联Observables
    static func +(lhs: Self, rhs: any ObservableConvertibleType) -> Completable {
        lhs.completed + rhs.completed
    }
}

extension ObservableConvertibleType {
	
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

#if os(iOS)
func <-> <Base>(textInput: TextInput<Base>, relay: BehaviorRelay<String>) -> Disposable {
    let bindToProperty = relay.bind(to: textInput.text)
    let bindToRelay = textInput.text.subscribe {
        [weak input = textInput.base] _ in
        /**
         In some cases `textInput.textRangeFromPosition(start, toPosition: end)` will return nil even though the underlying
         value is not nil. This appears to be an Apple bug. If it's not, and we are doing something wrong, please let us know.
         The can be reproed easily if replace bottom code with
         
         if nonMarkedTextValue != relay.value {
            relay.accept(nonMarkedTextValue ?? "")
         }

         and you hit "Done" button on keyboard.
         */
        if let input, let unmarkedText = input.unmarkedText, unmarkedText != relay.value {
            relay.accept(unmarkedText)
        }
        
    } onCompleted: {
        bindToProperty.dispose()
    }
    
    return Disposables.create(bindToProperty, bindToRelay)
}
#endif

func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    if T.self == String.self {
#if DEBUG && !os(macOS)
        fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx.text` property directly to relay.\n" +
            "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
            "REMEDY: Just use `textField <-> relay` instead of `textField.rx.text <-> relay`.\n" +
            "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
#endif
    }

    let bindToProperty = relay.bind(to: property)
    let bindToRelay = property.subscribe(onNext: relay.accept, onCompleted: bindToProperty.dispose)
    return Disposables.create(bindToProperty, bindToRelay)
}
