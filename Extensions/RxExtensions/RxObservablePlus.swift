//
//  RxObservablePlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/19.
//

import RxSwift

extension RxObservable {
    
    /// 合并Bool序列值 | 任意一个为true时发送true
    public static func eitherSatisfied<T>(_ observables: T...) -> RxObservable<T.Element> where T: ObservableConvertibleType, T.Element == Bool {
        eitherSatisfied(observables)
    }
    
    /// 合并Bool序列值 | 任意一个为true时发送true
    public static func eitherSatisfied<Collection: Swift.Collection>(_ collection: Collection) -> RxObservable<Collection.Element.Element> where Collection.Element: ObservableConvertibleType, Collection.Element.Element == Bool {
        RxObservable<Collection.Element.Element>.combineLatest(collection.map(\.observable)).map { bools in
            bools.set.contains(true)
        }
    }
    
    /// 合并Bool序列值
    /// - Parameter observables: Bool序列可变参数
    /// - Returns: Bool序列(全部满足为true时值为true)
    public static func allSatisfied<T>(_ observables: T...) -> RxObservable<T.Element> where T: ObservableConvertibleType, T.Element == Bool {
        allSatisfied(observables)
    }
    
    /// 合并Bool序列值 | 全部满足为true时发送true
    public static func allSatisfied<Collection: Swift.Collection>(_ collection: Collection) -> RxObservable<Collection.Element.Element> where Collection.Element: ObservableConvertibleType, Collection.Element.Element == Bool {
        RxObservable<Collection.Element.Element>.combineLatest(collection.map(\.observable)).map { bools in
            bools.allSatisfy(\.isTrue)
        }
    }
    
    /// 合并指定的序列数组 | 全部满足为true时发送true
    static func merge<T>(@ArrayBuilder<T> observablesBuilder: () -> [T]) -> RxObservable<T.Element> where T: ObservableConvertibleType {
        let observables = observablesBuilder()
        return observables.merged
    }
    
    /// 返回amb事件序列: 谁先发送事件就持续监听序列的事件
    /// - Parameter observablesBuilder: 监听序列构建
    /// - Returns: 最终订阅的事件序列
    static func amb<T>(@ArrayBuilder<T> observablesBuilder: () -> [T]) -> RxObservable<T.Element> where T: ObservableConvertibleType {
        let observables = observablesBuilder().map(\.observable)
        return RxObservable<T.Element>.amb(observables)
    }
}

extension RxObservable where Element == Error {
    
    func tryAfter(_ timeInterval: RxTimeInterval, maxRetryCount: Int) -> RxObservable<Int> {
        enumerated().flatMap { index, error -> RxObservable<Int> in
            guard index < maxRetryCount else {
                return .error(error).observe(on: MainScheduler.asyncInstance)
            }
            return .just(0).delay(timeInterval, scheduler: MainScheduler.asyncInstance)
        }
    }
}
