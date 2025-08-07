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
            Observable.just(0).delay($0, scheduler: scheduler).completable
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

final class ControlPropertyCoordinator<Button: UIButton, Property: Hashable>: NSObject {
    /// [属性:按钮]字典
    typealias PropertyButtonMap = [Property: Button]
    
    /// 按钮映射字典
    private let propertyButtonMap: PropertyButtonMap
    /// ReferenceWritableKeyPath对象
    private let keyPath: KeyPath<Button, Property>
    /// 源事件序列
    private let sharedSequence: Observable<[Button].ControlEventElement>
    /// 储存选中的按钮
    private weak var selectedButton: Button?
    /// Property
    var property: Property? {
        get {
            selectedButton.map { button in
                button[keyPath: keyPath]
            }
        }
        set(newProperty) {
            /// property有变动才执行后续操作
            guard self.property != newProperty else { return }
            /// 属性有效
            if let newProperty {
                /// 目标按钮
                guard let button = propertyButtonMap[newProperty] else { return }
                /// 发送事件
                button.sendActions(for: .touchUpInside)
            }
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - initialValue: 初始值
    ///   - buttons: 按钮数组
    ///   - keyPath: KeyPath
    ///   - eventFilter: 事件过滤闭包
    init(startWith initialValue: Property?,
         buttons: [Button],
         keyPath: KeyPath<Button, Property>,
         eventFilter: RxElementFilter<Button>? = nil)
    {
        /// 建立映射
        var propertyButtonMap = PropertyButtonMap.empty
        /// 找出第一个需要选中的按钮
        var firstButton: Button?
        /// 遍历按钮
        for button in buttons {
            /// 从buttons中找到指定值
            let buttonProperty = button[keyPath: keyPath]
            /// 更新键值映射
            propertyButtonMap[buttonProperty] = button
            /// 如果和初始值匹配则储存为第一个选中按钮
            if initialValue == buttonProperty {
                firstButton = button
            }
        }
        /// 更新映射属性
        self.propertyButtonMap = propertyButtonMap
        /// 保存KeyPath
        self.keyPath = keyPath
        /// 生成序列 | 同时储存选中的按钮
        self.sharedSequence = buttons.switchButtonEvent(.touchUpInside, startWith: firstButton, eventFilter: eventFilter).share(replay: 1)
        /// 父类初始化
        super.init()
        /// 内部订阅(给selectedButton赋值)
        self.sharedSequence
            .assign(\.0, to: rx.selectedButton)
            .subscribe()
            .disposed(by: rx.disposeBag)
    }
    
    /// 生成ControlProperty(使用计算属性而不是lazy var避免循环引用)
    var controlProperty: ControlProperty<Property?> {
        /// 只接受event非空的事件(即用户点击事件)
        let values = sharedSequence.filter(\.1.isValid).withUnretained(keyPath).map { keyPath, event in
            event.0[keyPath: keyPath]
        }
        /// 设置属性
        let valueSink = Binder<Property?>(self) { weakSelf, property in
            weakSelf.property = property
        }
        return ControlProperty(values: values.optionalElement, valueSink: valueSink)
    }
}

extension Array where Element: UIButton {
    
    /// ControlEvent元素
    typealias ControlEventElement = RxControlEventElement<Element>
    
    /// 按钮数组转换为ControlProperty
    /// - Parameters:
    ///   - initialValue: 初始值
    ///   - keyPath: KeyPath
    ///   - eventFilter: 按钮点击事件过滤闭包
    /// - Returns: ControlProperty
    func controlPropertyCoordinator<T: Hashable>(
        startWith initialValue: T? = nil,
        keyPath: KeyPath<Element, T>,
        eventFilter: RxElementFilter<Element>? = nil) -> ControlPropertyCoordinator<Element, T>
    {
        ControlPropertyCoordinator(startWith: initialValue, buttons: self, keyPath: keyPath, eventFilter: eventFilter)
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
        eventFilter: RxElementFilter<Element>? = nil) -> Observable<Element>
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
        eventFilter: RxElementFilter<Element>? = nil) -> Observable<Element>
    {
        switchButtonEvent(controlEvents, startWith: firstButton, eventFilter: eventFilter).map(\.0)
    }
    
    func switchButtonEvent(
        _ controlEvents: UIControl.Event = .touchUpInside,
        startIndex: Index? = nil,
        eventFilter: RxElementFilter<Element>? = nil) -> Observable<ControlEventElement>
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
        eventFilter: RxElementFilter<Element>? = nil) -> Observable<ControlEventElement>
    {
        mergedControlEvent(controlEvents, startWith: firstButton, eventFilter: eventFilter).lastAndLatest.compactMap {
            lastEvent, event -> ControlEventElement? in
            /// 上一个按钮取消选中
            if let lastEvent {
                /// 重复的按钮不发送事件
                if event.0 === lastEvent.0 {
                    return nil
                }
                /// 取消选中上一个按钮
                else {
                    lastEvent.0.isSelected = false
                }
            }
            /// 选中最新的按钮
            event.0.isSelected = true
            /// 返回事件元组
            return event
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
        eventFilter: RxElementFilter<Element>? = nil) -> Observable<ControlEventElement>
    {
        /// 第一个元素
        let firstElement = firstButton.flatMap { button -> ControlEventElement? in
            /// 元组
            let tuple: ControlEventElement = (button, nil)
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
