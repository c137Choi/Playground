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

extension Array where Element: ObservableConvertibleType {
    var merged: Observable<Element.Element> {
        Observable.from(self).merge()
    }
}

// MARK: - __________ UIButton+Rx __________
extension Observable where Element: UIButton {
    func matches(button: UIButton) -> Observable<Bool> {
        map { $0 == button }
    }
}

extension Array where Element: UIButton {
    
    /// 点击事件过滤
    typealias TapEventFilter = (Int, Element) -> Bool
    /// 切换选中的按钮
    /// - Parameter startIndex: 初次选中的按钮索引
    /// - Parameter toggleSelectedButton: 重复点击按钮是否切换选中状态
    /// - Returns: 选中按钮的事件序列
    func switchSelectedButton(startIndex: Index?, toggleSelectedButton: Bool = false, eventFilter: TapEventFilter? = nil) -> Observable<Element> {
        switchSelectedButton(
            startButton: startIndex.flatMap { index in
                element(at: index)
            },
            toggleSelectedButton: toggleSelectedButton,
            eventFilter: eventFilter
        )
    }
    
    /// 切换选中的按钮
    /// - Parameter firstSelected: 第一个选中的按钮
    /// - Returns: 选中按钮的事件序列
    func switchSelectedButton(startButton firstSelected: Element? = nil, toggleSelectedButton: Bool = false, eventFilter: TapEventFilter? = nil) -> Observable<Element> {
        let selectedButton = mergeTappedButton(eventFilter)
            .optionalElement
            .startWith(firstSelected)
            .unwrapped
        let disposable = handleSelectedButton(selectedButton, toggleSelectedButton: toggleSelectedButton)
        return selectedButton.do(onDispose: disposable.dispose)
    }
    
    /// 处理按钮选中/反选
    /// - Parameter selectedButton: 选中按钮的事件序列
    /// - Returns: Disposable
    private func handleSelectedButton(_ selectedButton: Observable<Element>, toggleSelectedButton: Bool = false) -> Disposable {
        selectedButton.scan([]) { lastResult, nextButton -> [Element] in
            
            /// 处理最新点击的按钮
            if toggleSelectedButton {
                nextButton.isSelected.toggle()
            } else {
                nextButton.isSelected = true
            }
            
            var buttons = lastResult
            /// 按钮数组不包含按钮的时候,将点击的按钮添加到数组
            if !buttons.contains(nextButton) {
                buttons.append(nextButton)
            }
            if buttons.count == 2 {
                /// 移除上一个按钮并取消选中
                let lastSelected = buttons.removeFirst()
                lastSelected.isSelected = false
            }
            return buttons
        }
        .subscribe()
    }
    
    /// 合并所有按钮的点击事件 | 按钮点击之后发送按钮对象自己
    /// - Parameter eventFilter: 事件过滤闭包
    func mergeTappedButton(_ eventFilter: TapEventFilter?) -> Observable<Element> {
        let tappedButtonEvents = enumerated().map { iteratorElement -> Observable<Element> in
            /// 数组中的索引
            let offset = iteratorElement.offset
            /// 按钮对象
            let button = iteratorElement.element
            /// 事件过滤
            if let eventFilter {
                return button.rx.tapButton.compactMap { btn in
                    eventFilter(offset, btn) ? btn : nil
                }
            } else {
                return button.rx.tapButton.observable
            }
        }
        return tappedButtonEvents.merged
    }
}
