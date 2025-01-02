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
                property.filter(\.itself).map(\.toggled).bind(to: otherControlProperty)
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
    
    /// 返回选中按钮ControlProperty
    /// - Parameter firstSelected: 首次选中的按钮
    /// - Returns: ControlProperty<Element?>
    func selectedButton(startWith firstSelected: Element?) -> ControlProperty<Element?> {
        let values = switchSelectedButton(startButton: firstSelected).optionalElement
        let observer = AnyObserver<Element?> { event in
            switch event {
            case .next(let button) where button.isVoid:
                first(where: \.isSelected)?.isSelected = false
            default:
                break
            }
        }
        return ControlProperty(values: values, valueSink: observer)
    }
    
    /// 切换选中的按钮
    /// - Parameter firstSelection: 按钮在数组中的索引
    /// - Returns: 选中按钮的事件序列
    func switchSelectedButton(startIndex firstSelection: Self.Index? = nil, toggleSelectedButton: Bool = false) -> Observable<Element> {
        if let firstSelection {
            guard let selectedButton = itemAt(firstSelection) else {
                return switchSelectedButton(startButton: nil, toggleSelectedButton: toggleSelectedButton)
            }
            return switchSelectedButton(startButton: selectedButton, toggleSelectedButton: toggleSelectedButton)
        } else {
            return switchSelectedButton(startButton: nil, toggleSelectedButton: toggleSelectedButton)
        }
    }
    
    /// 切换选中的按钮
    /// - Parameter firstSelected: 第一个选中的按钮
    /// - Returns: 选中按钮的事件序列
    func switchSelectedButton(startButton firstSelected: Element? = nil, toggleSelectedButton: Bool = false) -> Observable<Element> {
        let selectedButton = tapButton
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
        selectedButton.scan([]) { lastResult, button -> [Element] in
            
            /// 处理最新点击的按钮
            if toggleSelectedButton {
                button.isSelected.toggle()
            } else {
                button.isSelected = true
            }
            
            var buttons = lastResult
            /// 按钮数组不包含按钮的时候,将点击的按钮添加到数组
            if buttons.contains(button).isFalse {
                buttons.append(button)
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
    public var tapButton: Observable<Element> {
        /// 写成map(\.rx.tapButton)这种形式编译出错(2024年10月16日14:11:19)
        let tappedButtonSequences = map { $0.rx.tapButton }
        return Observable.from(tappedButtonSequences).merge()
    }
}
