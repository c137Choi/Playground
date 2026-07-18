//
//  WeakPublished.swift
//  KnowLED
//
//  Created by Choi on 2026/6/17.
//

import Foundation
import Combine

nonisolated final class DeallocationSentinel: @unchecked Sendable {
    
    fileprivate var callbacks: [ObjectIdentifier: () -> Void] = [:]
    
    deinit {
        for callback in callbacks.values {
            callback()
        }
    }
}

// MARK: - DeallocationObservable协议
protocol DeallocationObservable: AnyObject {
    var deallocationSentinel: DeallocationSentinel { get }
}

/// NSObject遵循协议
extension NSObject: DeallocationObservable {}

/// DeallocationObservable协议默认实现
extension DeallocationObservable where Self: NSObject {
    var deallocationSentinel: DeallocationSentinel {
        if let existingHub = associated(DeallocationSentinel.self, self, Associated.deallocationSentinel) {
            return existingHub
        }
        let hub = DeallocationSentinel()
        setAssociatedObject(self, Associated.deallocationSentinel, hub, .OBJC_ASSOCIATION_RETAIN)
        return hub
    }
}

// MARK: - Implementations
@propertyWrapper
final class WeakPublished<Wrapped: DeallocationObservable> {
    
    private struct WeakBox {
        weak var value: Wrapped?
    }
    
    /// 用于发送通知
    private let subject: CurrentValueSubject<WeakBox, Never>
    
    /// 标记版本号: 防止旧对象的 sentinel 回调在新对象持有期间误触发
    private var version: UInt = 0
    
    var wrappedValue: Wrapped? {
        get { subject.value.value }
        set {
            version &+= 1
            if let newValue {
                attachSentinel(to: newValue, version: version)
            }
            subject << WeakBox(value: newValue)
        }
    }
    
    var projectedValue: AnyPublisher<Wrapped?, Never> {
        subject.map(\.value).eraseToAnyPublisher()
    }
    
    init(wrappedValue: Wrapped?) {
        self.subject = CurrentValueSubject(WeakBox(value: wrappedValue))
        if let wrappedValue {
            attachSentinel(to: wrappedValue, version: 0)
        }
    }
    
    private func attachSentinel(to target: Wrapped, version: UInt) {
        let observerID = ObjectIdentifier(self)
        target.deallocationSentinel.callbacks[observerID] = { [weak self] in
            guard let self, self.version == version else { return }
            self.subject << WeakBox(value: nil)
        }
    }
    
    /*
     说明:
     version的作用
     时刻1: @WeakPublished 赋值对象A
            → A.sentinel 注册 callback_A
     
     时刻2: @WeakPublished 赋值对象B
            → B.sentinel 注册 callback_B
            → 此时持有的是B，但A的sentinel中 callback_A 仍在

     时刻3: A 被释放
            → A.sentinel.deinit → callback_A 执行
            → subject.send(nil)  ← 💥 错误！当前持有的是B，不是nil
     
     有version的防护:
     时刻1: version = 1, 赋值对象A
            → callback_A 捕获 version = 1

     时刻2: version = 2, 赋值对象B
            → callback_B 捕获 version = 2

     时刻3: A 被释放
            → callback_A: self.version(2) == 捕获的version(1)? → ❌ 不匹配
            → 忽略，不发送 nil ✅

     时刻4: B 被释放
            → callback_B: self.version(2) == 捕获的version(2)? → ✅ 匹配
            → 发送 nil ✅
     
     字典Key用ObjectIdentifier的原因:
     关键场景1：同一个目标被多个 WeakPublished 观察
     两个 WeakPublished 指向同一个对象
     @WeakPublished var a: SomeController?
     @WeakPublished var b: SomeController?
     a = controller
     b = controller  // 同一个 controller
     此时 controller.deallocationSentinel.callbacks 中有两个条目：
     callbacks = [
         ObjectIdentifier(weakPublished_a) → callback_a,
         ObjectIdentifier(weakPublished_b) → callback_b
     ]
     对象释放时两个回调都触发，各自通知自己的 WeakPublished ，互不干扰。
     
     关键场景2：同一个 WeakPublished 重复赋值同一目标
     @WeakPublished var target: SomeController?
     target = controller   // version=1, 注册 callback
     target = controller   // version=2, 覆盖同一 key 的 callback
     ObjectIdentifier(self) 相同 → 字典 updateValue 覆盖旧回调，不会残留。如果用 UUID ，每次赋值生成新 key，旧回调永远不会被移除，对象释放时会触发过期的回调。
     */
}
