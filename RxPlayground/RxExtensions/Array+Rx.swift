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

// MARK: - ControlPropertyCoordinator
final class ControlPropertyCoordinator<Button: UIButton, Property: Hashable>: NSObject {
    /// [属性:按钮]字典
    typealias PropertyButtonMap = [Property: Button]
    /// 按钮触发事件
    typealias ButtonControlEvent = RxControlEventElement<Button>
    
    /// ReferenceWritableKeyPath对象
    private let keyPath: KeyPath<Button, Property>
    /// 按钮事件Subject
    private let buttonEventSubject = BehaviorSubject<ButtonControlEvent?>(value: nil)
    /// 按钮映射字典
    private var propertyButtonMap = PropertyButtonMap.empty
    /// 储存选中的按钮
    private weak var selectedButton: Button?
    /// 观察按钮切换
    private var switchingButtons: DisposeBag?
    /// 标记是否发送事件
    private var sendEvent = true
    /// 设置属性
    private lazy var propertySink = Binder<Property?>(self) { weakSelf, property in
        weakSelf.setProperty(property, sendEvent: false)
    }
    
    /// 初始化
    /// - Parameters:
    ///   - initialProperty: 初始值
    ///   - buttons: 按钮数组
    ///   - keyPath: KeyPath
    ///   - eventFilter: 事件过滤闭包
    init(startWith initialProperty: Property?, buttons: [Button], keyPath: KeyPath<Button, Property>, eventFilter: RxElementFilter<Button>? = nil) {
        /// 保存KeyPath
        self.keyPath = keyPath
        /// 父类初始化
        super.init()
        /// 监听按钮切换
        reload(buttons, initialProperty: initialProperty, eventFilter: eventFilter)
        /// 绑定选中按钮
        buttonEventSubject
            .unwrapped
            .map(\.0)
            .bind(to: rx.selectedButton)
            .disposed(by: rx.disposeBag)
    }
    
    /// 监听按钮切换
    /// - Parameters:
    ///   - buttons: 要切换的按钮
    ///   - firstButton: 首次选中的按钮
    ///   - eventFilter: 事件过滤闭包
    func reload(_ buttons: [Button], initialProperty: Property?, eventFilter: RxElementFilter<Button>? = nil) {
        /// 建立映射
        var tmpPropertyButtonMap = PropertyButtonMap.empty
        /// 找出第一个需要选中的按钮
        var firstButton: Button?
        /// 遍历要切换的按钮
        for button in buttons {
            /// 按钮属性
            let buttonProperty = button[keyPath: keyPath]
            /// 更新属性 -> 按钮映射
            tmpPropertyButtonMap[buttonProperty] = button
            /// 如果按钮属性和初始值匹配, 则将按钮储存为第一个选中按钮
            if initialProperty == buttonProperty {
                firstButton = button
            }
        }
        /// 更新映射属性
        self.propertyButtonMap = tmpPropertyButtonMap
        /// 持续观察按钮切换
        self.switchingButtons = DisposeBag {
            buttons.switchButtonEvent(.touchUpInside, startWith: firstButton, eventFilter: eventFilter)
                .optionalElement
                .multicast(buttonEventSubject)
                .connect()
        }
    }
    
    func setProperty(_ newProperty: Property?, sendEvent: Bool) {
        /// property有变动才执行后续操作
        guard self.property != newProperty else { return }
        /// 属性有效
        if let newProperty {
            /// 目标按钮
            guard let targetButton = propertyButtonMap[newProperty] else { return }
            /// (注意调用顺序)先标记是否发送事件
            self.sendEvent = sendEvent
            /// 再发送事件
            targetButton.sendActions(for: .touchUpInside)
        }
    }
    
    /// 属性: 设置属性时, 不发送事件
    var property: Property? {
        get {
            selectedButton.map { button in
                button[keyPath: keyPath]
            }
        }
        set {
            setProperty(newValue, sendEvent: false)
        }
    }
    
    var controlProperty: ControlProperty<Property?> {
        let values = buttonEventSubject.unwrapped.withUnretained(self).compactMap { weakSelf, event -> Property? in
            /// 如果不发送事件, 则直接返回空
            if !weakSelf.sendEvent {
                weakSelf.sendEvent = true
                return nil
            }
            /// 返回按钮属性
            return event.0[keyPath: weakSelf.keyPath]
        }
        return ControlProperty(values: values.optionalElement, valueSink: propertySink)
    }
    
    /// 用户交互后才发送事件的ControlProperty
    var interactiveControlProperty: ControlProperty<Property?> {
        let interactiveValues = buttonEventSubject
            .enumerated()
            .compactMap { index, tuple -> ButtonControlEvent? in
                if let tuple {
                    /// 首次订阅UIEvent保持为空
                    if index == 0 {
                        return (tuple.0, nil)
                    } else {
                        return tuple
                    }
                } else {
                    return nil
                }
            }
            .filter(\.1.isValid) // 只接受event非空的事件(即用户点击事件)
            .withUnretained(keyPath)
            .map { keyPath, event in
                event.0[keyPath: keyPath]
            }
        return ControlProperty(values: interactiveValues.optionalElement, valueSink: propertySink)
    }
}
