//
//  Array+Rx.swift
//  RxPlayground
//
//  Created by Choi on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa

extension Array where Element == ControlProperty<Bool> {
    
    /// 让数组里的ControlProperty<Bool>互斥(开启一个的时候其它的全部关闭)
    var mutualExclusion: Disposable {
        let disposables = enumerated().flatMap { index, property in
            var currentExcluded = self
            currentExcluded.remove(at: index)
            return currentExcluded.map { otherControlProperty in
                property.filter(\.itself).map(\.opposite).bind(to: otherControlProperty)
            }
        }
        return Disposables.create(disposables)
    }
}

extension Array where Element: ObservableConvertibleType {
    
    var merged: Observable<Element.Element> {
        Observable.from(self).merge()
    }
    
    /// 串联事件序列数组(无时间间隔)
    var chained: Completable {
        chained(pauseInterval: nil)
    }
    
    /// 串联事件序列数组
    /// - Parameters:
    ///   - pauseInterval: 序列之间的停顿时间(首尾的序列不添加停顿时间)
    ///   - scheduler: 执行时间间隔的调度器 | interval非空才有意义
    /// - Returns: Completable
    func chained(pauseInterval: RxTimeInterval? = nil, scheduler: SchedulerType = MainScheduler.instance) -> Completable {
        /// 确保数组非空
        guard isNotEmpty else {
            return .empty()
        }
        /// 间隔序列
        let pause = pauseInterval.map {
            Observable.just(0).delay($0, scheduler: scheduler).completed
        }
        return enumerated().reduce(Completable.empty) { completable, tuple in
            /// 下一个Completable事件序列
            let nextCompletable = tuple.element.completed
            /// 中间的序列
            let isMiddleSequence = tuple.offset != startIndex && tuple.offset != lastIndex
            /// 不是第一个 && 时间间隔非空
            if let pause, isMiddleSequence {
                return completable + pause.andThen(nextCompletable)
            } else {
                return completable + nextCompletable
            }
        }
    }
}

fileprivate final class ButtonPropertyObserver<Button, T>: ObserverType, ReactiveCompatible where Button: UIButton, T: Hashable {
    typealias Element = T
    
    var lastButton: Button?
    
    private var keyButtonMap: [T: Button]
    
    init(buttons: [Button], keyPath: ReferenceWritableKeyPath<Button, T>) {
        keyButtonMap = buttons.reduce(into: [T: Button].empty) { dict, button in
            let key = button[keyPath: keyPath]
            dict[key] = button
        }
    }
    
    func on(_ event: Event<T>) {
        if case .next(let key) = event {
            DispatchQueue.main.async {
                [weak self] in
                guard let self else { return }
                /// 目标按钮
                let targetButton = keyButtonMap[key]
                /// 相同的按钮直接跳过
                if lastButton === targetButton { return }
                /// 上一个按钮取消选中
                lastButton?.isSelected = false
                /// 选中目标按钮
                targetButton?.isSelected = true
                /// 标记为上一个按钮
                lastButton = targetButton
            }
        }
    }
}

extension Array where Element: UIButton {
    
    /// 点击事件过滤
    typealias TapEventFilter = (Int, Element) -> Bool
    
    func controlPropertySwitchSelectedButton<T: Hashable>(startIndex: Index?, keyPath: ReferenceWritableKeyPath<Element, T>, eventFilter: TapEventFilter? = nil) -> ControlProperty<T> {
        let observer = ButtonPropertyObserver<Element, T>(buttons: self, keyPath: keyPath)
        let values = switchSelectedButton(startIndex: startIndex, eventFilter: eventFilter).assign(to: observer.rx.lastButton).map { button in
            button[keyPath: keyPath]
        }
        return ControlProperty(values: values, valueSink: observer)
    }
    
    /// 切换选中的按钮
    /// - Parameters:
    ///   - startIndex: 第一个选中的按钮索引
    ///   - eventFilter: 事件过滤闭包
    /// - Returns: 选中的按钮事件序列
    func switchSelectedButton(startIndex: Index?, eventFilter: TapEventFilter? = nil) -> Observable<Element> {
        switchSelectedButton(startWith: startIndex.flatMap(element(at:)), eventFilter: eventFilter)
    }
    
    /// 切换选中的按钮
    /// - Parameters:
    ///   - first: 第一个要选中的按钮
    ///   - eventFilter: 事件过滤闭包
    /// - Returns: 选中的按钮事件序列
    func switchSelectedButton(startWith first: Element? = nil, eventFilter: TapEventFilter? = nil) -> Observable<Element> {
        tappedButton(startWith: first, eventFilter: eventFilter).lastAndLatest.compactMap { lastButton, button -> Element? in
            /// 上一个按钮取消选中
            if let lastButton {
                if button === lastButton {
                    return nil
                } else {
                    lastButton.isSelected = false
                }
            }
            /// 选中最新的按钮
            button.isSelected = true
            /// 返回最新按钮
            return button
        }
    }
    
    /// 合并所有按钮的点击事件 | 按钮点击之后发送按钮对象自己
    /// - Parameters:
    ///   - first: 第一个要选中的按钮
    ///   - eventFilter: 事件过滤闭包
    /// - Returns: 按钮事件序列
    fileprivate func tappedButton(startWith first: Element?, eventFilter: TapEventFilter?) -> Observable<Element> {
        /// 第一个发送的按钮
        let startButton = first.flatMap { firstButton -> Element? in
            /// 查找第一个按钮在数组中的索引. 如果不在数组中则返回空
            guard let firstButtonIndex = firstIndex(of: firstButton) else { return nil }
            /// 如果有事件过滤
            if let eventFilter {
                /// 调用: 评估通过后返回第一个按钮, 否则返回空
                return eventFilter(firstButtonIndex, firstButton) ? firstButton : nil
            } else {
                /// 无事件过滤, 直接返回第一个按钮
                return firstButton
            }
        }
        let tappedButtonEvents = enumerated().map { offset, button -> Observable<Element> in
            eventFilter.map(fallback: button.rx.tapButton) { filter in
                button.rx.tapButton.filter { btn in
                    filter(offset, btn)
                }
            }
        }
        return tappedButtonEvents.merged
            .optionalElement
            .startWith(startButton)
            .unwrapped
    }
}
