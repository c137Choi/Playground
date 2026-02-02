//
//  Array+Rx.swift
//  RxPlayground
//
//  Created by Choi on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa

typealias RxElementFilter<T> = (Int, T) -> Bool

// MARK: - [any ObservableConvertibleType] Extension
extension Array where Element: ObservableConvertibleType {
    
    var merged: RxObservable<Element.Element> {
        RxObservable.from(self).merge()
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
            RxObservable.just(0).delay($0, scheduler: scheduler).completable
        }
        return enumerated().reduce(Completable.empty) { completable, tuple in
            /// 下一个Completable事件序列
            let nextCompletable = tuple.element.completable
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

// MARK: - [UIButton] Extension
extension Array where Element: UIButton {
    
    /// ControlEvent元素
    typealias RxElement = EnhancedControlEvent<Element>
    
    /// 按钮数组转换为ControlProperty
    /// - Parameters:
    ///   - initialValue: 初始值
    ///   - keyPath: KeyPath
    ///   - eventFilter: 按钮点击事件过滤闭包
    /// - Returns: ControlProperty
    func controlPropertyCoordinator<T: Hashable>(
        startWith initialValue: T? = nil,
        keyPath: KeyPath<Element, T>,
        eventFilter: RxElementFilter<Element>? = nil) -> ButtonControlPropertyCoordinator<Element, T>
    {
        ButtonControlPropertyCoordinator(startWith: initialValue, buttons: self, keyPath: keyPath, eventFilter: eventFilter)
    }
    
    /// 切换选中的按钮
    /// - Parameters:
    ///   - controlEvents: 切换按钮需要执行的事件
    ///   - startIndex: 第一个选中的按钮索引
    ///   - eventFilter: 按钮点击事件过滤闭包
    /// - Returns: 选中的按钮事件序列
    func switchButton(
        _ controlEvents: UIControl.Event = .touchUpInside,
        startIndex: Index?,
        eventFilter: RxElementFilter<Element>? = nil) -> RxObservable<Element>
    {
        switchButton(controlEvents, startWith: element(at: startIndex), eventFilter: eventFilter)
    }
    
    /// 切换选中的按钮
    /// - Parameters:
    ///   - controlEvents: 切换按钮需要执行的事件
    ///   - firstButton: 第一个要选中的按钮
    ///   - eventFilter: 按钮点击事件过滤闭包
    /// - Returns: 选中的按钮事件序列
    func switchButton(
        _ controlEvents: UIControl.Event = .touchUpInside,
        startWith firstButton: Element? = nil,
        eventFilter: RxElementFilter<Element>? = nil) -> RxObservable<Element>
    {
        switchButtonEvent(controlEvents, startWith: firstButton, eventFilter: eventFilter).map(\.0)
    }
    
    func switchButtonEvent(
        _ controlEvents: UIControl.Event = .touchUpInside,
        startIndex: Index? = nil,
        eventFilter: RxElementFilter<Element>? = nil) -> RxObservable<RxElement>
    {
        switchButtonEvent(controlEvents, startWith: element(at: startIndex), eventFilter: eventFilter)
    }
    
    /// 切换选中的按钮
    /// - Parameters:
    ///   - controlEvents: 切换按钮需要执行的事件
    ///   - firstButton: 第一个要选中的按钮
    ///   - eventFilter: 按钮点击事件过滤闭包
    /// - Returns: 选中的按钮事件序列
    func switchButtonEvent(
        _ controlEvents: UIControl.Event = .touchUpInside,
        startWith firstButton: Element? = nil,
        eventFilter: RxElementFilter<Element>? = nil) -> RxObservable<RxElement>
    {
        mergedControlEvent(controlEvents, startWith: firstButton, eventFilter: eventFilter).lastAndLatest.compactMap {
            lastControlEvent, controlEvent -> RxElement? in
            /// 上一个按钮取消选中
            if let lastControlEvent {
                /// 重复点击按钮不发送事件
                if controlEvent.control === lastControlEvent.control {
                    return nil
                }
                /// 取消选中上一个按钮
                else {
                    lastControlEvent.control.isSelected = false
                }
            }
            /// 选中最新的按钮
            controlEvent.control.isSelected = true
            /// 返回事件元组
            return controlEvent
        }
    }
    
    /// 合并所有按钮的点击事件 | 按钮点击之后发送按钮对象自己
    /// - Parameters:
    ///   - firstButton: 第一个要选中的按钮
    ///   - eventFilter: 按钮点击事件过滤闭包
    /// - Returns: 按钮事件序列
    fileprivate func mergedControlEvent(
        _ controlEvents: UIControl.Event,
        startWith firstButton: Element?,
        eventFilter: RxElementFilter<Element>? = nil) -> RxObservable<RxElement>
    {
        /// 第一个元素
        let firstElement = firstButton.flatMap { button -> RxElement? in
            /// 元组
            let tuple: RxElement = (button, nil)
            /// 如果有事件过滤
            if let eventFilter {
                /// 查找第一个按钮在数组中的索引. 如果不在数组中则返回空
                guard let index = firstIndex(of: button) else { return nil }
                /// 调用: 评估通过后返回第一个按钮, 否则返回空
                return eventFilter(index, button) ? tuple : nil
            } else {
                /// 无事件过滤, 直接返回元组
                return tuple
            }
        }
        let enhancedControlEvents = enumerated().map { index, element in
            /// 事件序列
            let controlEvent = element.rx.enhancedControlEvent(controlEvents).observable
            /// 过滤事件
            return eventFilter.map(fallback: controlEvent) { eventFilter in
                controlEvent.filter { button, _ in
                    eventFilter(index, button)
                }
            }
        }
        return enhancedControlEvents.merged
            .optionalElement
            .startWith(firstElement)
            .unwrapped
    }
}
