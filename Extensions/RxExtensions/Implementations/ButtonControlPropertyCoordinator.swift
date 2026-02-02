//
//  ButtonControlPropertyCoordinator.swift
//  KnowLED
//
//  Created by Choi on 2026/2/2.
//

import UIKit
import RxSwift
import RxCocoa

final class ButtonControlPropertyCoordinator<Button: UIButton, Property: Hashable>: NSObject {
    /// [属性:按钮]字典
    typealias PropertyButtonMap = [Property: Button]
    /// 按钮触发事件
    typealias ButtonEvent = EnhancedControlEvent<Button>
    
    /// KeyPath对象
    private let keyPath: KeyPath<Button, Property>
    /// 按钮事件Relay
    private let buttonEventRelay = BehaviorRelay<ButtonEvent?>(value: nil)
    /// 按钮映射字典
    private var propertyButtonMap = PropertyButtonMap.empty
    /// 储存选中的按钮
    private weak var selectedButton: Button?
    /// 观察按钮切换
    private var switchingButtons: DisposeBag?
    /// 标记是否发送事件
    private var sendEvent = true
    /// 设置属性
    private lazy var sinkProperty = Binder<Property?>(self) {
        $0.setProperty($1, sendEvent: false)
    }
    
    /// 初始化
    /// - Parameters:
    ///   - initialProperty: 初始值
    ///   - buttons: 按钮数组
    ///   - keyPath: KeyPath
    ///   - eventFilter: 事件过滤闭包
    init(startWith initialProperty: Property? = nil, buttons: [Button] = .empty, keyPath: KeyPath<Button, Property>, eventFilter: RxElementFilter<Button>? = nil) {
        /// 保存KeyPath
        self.keyPath = keyPath
        /// 父类初始化
        super.init()
        /// 监听按钮切换
        reload(buttons, initialProperty: initialProperty, eventFilter: eventFilter)
    }
    
    /// 监听按钮切换
    /// - Parameters:
    ///   - buttons: 要切换的按钮
    ///   - firstButton: 首次选中的按钮
    ///   - eventFilter: 事件过滤闭包
    func reload(_ buttons: [Button], initialProperty: Property? = nil, eventFilter: RxElementFilter<Button>? = nil) {
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
            buttons.switchButtonEvent(.touchUpInside, startWith: firstButton, eventFilter: eventFilter).subscribe {
                [unowned self] rxEvent in
                /// 这里要检查element非空, 考虑按钮数组为空的时候发送completed事件给subject导致事件序列结束的情况
                guard let controlEvent = rxEvent.element else { return }
                /// 保存选中的按钮
                selectedButton = controlEvent.control
                /// 转发到subject
                buttonEventRelay.accept(controlEvent)
            }
        }
    }
    
    func setProperty(_ newProperty: Property?, sendEvent: Bool) {
        /// property有变动才执行后续操作
        guard property != newProperty else { return }
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
        let values = buttonEventRelay.compactMap {
            [weak self] buttonEvent -> Property? in
            guard let self, let button = buttonEvent.map(\.control) else { return nil }
            /// 如果标记为不发送事件则直接返回
            if !sendEvent {
                sendEvent = true
                return nil
            }
            /// 返回Property
            return button[keyPath: keyPath]
        }
        return ControlProperty(values: values.optionalElement.take(until: rx.deallocated), valueSink: sinkProperty)
    }
    
    /// 用户交互后才发送事件的ControlProperty
    var interactiveControlProperty: ControlProperty<Property?> {
        let interactiveValues = buttonEventRelay.enumerated().compactMap {
            [weak keyPath] index, buttonEvent -> Property? in
            guard let keyPath, let buttonEvent else { return nil }
            /// 首次订阅不发送事件(有第二个订阅者的时候防止订阅到之前的缓存)
            if index == 0 {
                return nil
            } else {
                /// UIEvent非空为用户交互事件
                return buttonEvent.event.isValid ? buttonEvent.control[keyPath: keyPath] : nil
            }
        }
        return ControlProperty(values: interactiveValues.optionalElement.take(until: rx.deallocated), valueSink: sinkProperty)
    }
}
