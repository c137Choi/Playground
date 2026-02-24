//
//  Configurable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

public protocol Configurable {}

public protocol SimpleInitializer {
    init()
}

extension Configurable {
    
    /// 转换
    /// - Parameter transformer: 转换闭包
    /// - Returns: 转换后的类型
    func transform<T>(_ transformer: (Self) throws -> T) rethrows -> T {
        try transformer(self)
    }
    
    func transform<T>(fallback: T, _ transformer: (Self) throws -> T?) rethrows -> T {
        try transformer(self) ?? fallback
    }
    
    /// 通过KeyPath更新属性:
    /// - Parameters:
    ///   - keyPath: KeyPath
    ///   - value: 新值
    /// - Returns: 值类型返回拷贝对象. 引用类型返回其自身
    func with<T>(new keyPath: WritableKeyPath<Self, T>, _ value: T) -> Self {
        with { make in
            make[keyPath: keyPath] = value
        }
    }
    
    /// 配置
    /// - Parameter setup: 配置闭包
    /// - Returns: 值类型返回拷贝对象. 引用类型返回自身
    func with(setup: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try setup(&copy)
        return copy
    }
    
    @discardableResult
    mutating func setup(_ setup: (inout Self) throws -> Void) rethrows -> Self {
        try setup(&self)
        return self
    }
}

/// 为引用类型另外定义扩展方法, 方便对let对象直接调用方法
extension Configurable where Self: AnyObject {
    
    @discardableResult
    func setup(_ setup: (Self) throws -> Void) rethrows -> Self {
        try setup(self)
        return self
    }
}

extension Configurable where Self: SimpleInitializer & AnyObject {
    
    /// 创建并初始化实例
    /// - Parameter setup: 初始化配置
    /// - Returns: 返回实例
    static func make(_ setup: (Self) throws -> Void) rethrows -> Self {
        let instance = self.init()
        try setup(instance)
        return instance
    }
}

extension NSObject: SimpleInitializer {}

extension NSObject: Configurable {}
extension URLRequest: Configurable {}
extension Int: Configurable {}
extension Double: Configurable {}
extension String: Configurable {}
extension Array: Configurable {}
extension Calendar: Configurable {}
extension Dictionary: Configurable {}
extension DateComponents: Configurable {}
extension Set: Configurable {}
extension CGRect: Configurable {}
extension CGSize: Configurable {}
extension CGPoint: Configurable {}
extension UIEdgeInsets: Configurable {}
extension NSDirectionalEdgeInsets: Configurable {}

@available(iOS 16, *)
extension LocalizedStringResource: Configurable {}

@available(iOS 15, *)
extension AttributeContainer: Configurable {}

@available(iOS 15, *)
extension Date.FormatStyle: Configurable {}
