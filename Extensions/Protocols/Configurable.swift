//
//  Configurable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

public protocol Configurable {}

public protocol ReferenceConfigurable: AnyObject {}

public protocol SimpleInitializer {
    init()
}

// MARK: - Conforming Types
extension NSObject: SimpleInitializer {}
extension NSObject: ReferenceConfigurable {}

extension Array: Configurable {}
extension Calendar: Configurable {}
extension Dictionary: Configurable {}
extension DateComponents: Configurable {}
extension Set: Configurable {}
extension CGRect: Configurable {}
extension CGSize: Configurable {}
extension CGPoint: Configurable {}
extension UIEdgeInsets: Configurable {}

// MARK: - 协议实现
extension Configurable {
    
    /// 变形: 将自身转换成其他类型
    /// - Parameter transformer: 转换闭包
    func transform<T>(_ transformer: (Self) -> T) -> T {
        transformer(self)
    }
    
    /// 拷贝自身, 并根据KeyPath为拷贝赋值, 最后返回拷贝 | 用于值类型
    func with<T>(new keyPath: WritableKeyPath<Self, T>, _ value: T) -> Self {
        with { make in
            make[keyPath: keyPath] = value
        }
    }
    
    /// 拷贝自身, 并对自身的拷贝进行配置, 最后返回拷贝 | 用于值类型
    func with(configuration: (inout Self) throws -> Void) rethrows -> Self {
        var clone = self
        try configuration(&clone)
        return clone
    }
}

extension ReferenceConfigurable {
    
    /// 变形: 将自身转换成其他类型
    /// - Parameter transformer: 转换闭包
    func transform<T>(_ transformer: (Self) -> T) -> T {
        transformer(self)
    }
    
    /// 对自身进行配置并返回自身
    @discardableResult
    func configure(_ configuration: (Self) throws -> Void) rethrows -> Self {
        try configuration(self)
        return self
    }
    
    /// 通过ReferenceWritableKeyPath更新属性并返回自身
    @discardableResult
    func with<T>(new keyPath: ReferenceWritableKeyPath<Self, T>, _ value: T) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
}

extension SimpleInitializer where Self: ReferenceConfigurable {
    
    static func make(_ configuration: (Self) -> Void) -> Self {
        self.init().configure(configuration)
    }
}
