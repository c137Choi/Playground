//
//  ObservableTypePlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/19.
//

import RxSwift

extension ObservableType {
    
    /// 转换成指定的类型 | 转换失败则不发送事件
    /// - Parameter type: 转换的类型
    /// - Returns: Observable
    public func compactMap<T>(_ type: T.Type) -> Observable<T> {
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
    public func asOptional<T>(_ type: T.Type) -> Observable<T?> {
        map { element in element as? T }
    }
    
    /// 转换成指定类型 | 如果转换失败则序列抛出错误
    /// - Parameter type: 转换的类型
    /// - Returns: Observable
    public func `as`<T>(_ type: T.Type) -> Observable<T> {
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
