//
//  RxPropertyWrappers.swift
//  KnowLED
//
//  Created by Choi on 2025/7/19.
//

import RxSwift
import RxCocoa

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
    var conditionalValue: RxObservable<Wrapped> {
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
    
    var skipFirst: RxObservable<Wrapped> {
        relay.skip(1)
    }
    
    func asObservable() -> RxSwift.RxObservable<Wrapped> {
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
    
    var rangeBoundError: RxObservable<RangeBoundError> {
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
    
    func asObservable() -> RxSwift.RxObservable<Wrapped?> {
        subject.startWith(weakReference)
    }
    
    func subscribe<Observer>(_ observer: Observer) -> any Disposable where Observer : ObserverType, Observer.Element == Wrapped? {
        asObservable().subscribe(observer)
    }
}
