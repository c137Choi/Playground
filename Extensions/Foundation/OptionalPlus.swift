//
//  OptionalPlus.swift
//
//  Created by Choi on 2022/8/18.
//

import Foundation

extension Optional {
    
    var isVoid: Bool {
        !isValid
    }
    
    var isValid: Bool {
        switch self {
        case .none:
            false
        case .some:
            true
        }
    }
    
    /// 转换为Any类型
    var asAny: Any {
        self as Any
    }
    
    /// 过滤指定条件
    /// - Parameter predicate: 过滤条件
    /// - Returns: 满足指定条件的结果
    func filter(_ predicate: (Wrapped) -> Bool) -> Wrapped? {
        guard let unwrapped = self, predicate(unwrapped) else { return nil }
        return unwrapped
    }
    
    /// 只有自身为空时才赋值
    public mutating func fillVoid(_ wrapped: Wrapped?) {
        guard isVoid else { return }
        self = wrapped
    }
    
    /// 映射,失败后返回默认值
    public func map<U>(_ transform: (Wrapped) throws -> U, fallback: @autoclosure () -> U) rethrows -> U {
        try self.map(transform) ?? fallback()
    }
    
    public func map<U>(_ transform: (Wrapped) throws -> U, fallback: () -> U) rethrows -> U {
        try self.map(transform) ?? fallback()
    }
    
    /// 映射,失败后返回默认值
    public func flatMap<U>(_ transform: (Wrapped) throws -> U?, fallback: @autoclosure () -> U) rethrows -> U {
        try self.flatMap(transform) ?? fallback()
    }
    
    public func flatMap<U>(_ transform: (Wrapped) throws -> U?, fallback: () -> U) rethrows -> U {
        try self.flatMap(transform) ?? fallback()
    }
    
    /// 解包->执行Closure->更新自身的值
    /// 普通的unwrap方法不会触发通知
    /// - Parameters:
    ///   - execute: 执行的闭包
    ///   - failed: 失败回调
    /// - Returns: 解包后的值
    @discardableResult
    mutating func mutating(execute: (inout Wrapped) throws -> Void, failed: SimpleCallback = {}) rethrows -> Wrapped? {
        guard var wrapped = self else {
            failed()
            return nil
        }
        try execute(&wrapped)
        self = wrapped
        return wrapped
    }
    
    /// 如果不为空则以解包后的值作为入参执行闭包
    /// - Parameter execute: 回调闭包
    /// - Parameter failed: 失败回调 | 因为Optional类型的closure会被推断为@escaping closure, 所以这里不能使用SimpleCallback?类型作为失败的回调
    /// - Returns: Optional<Wrapped>
    @discardableResult 
    func unwrap(execute: (Wrapped) throws -> Void, failed: SimpleCallback = {}) rethrows -> Wrapped? {
        switch self {
        case .none:
            failed()
            return nil
        case .some(let wrapped):
            try execute(wrapped)
            return wrapped
        }
    }
    
    /// 解包Optional类型
    /// - Parameter error: 解包失败时抛出的错误
    /// - Returns: 解包成功后返回Wrapped
    func unwrap(failed error: Error) throws -> Wrapped {
        guard let self else {
            throw error
        }
        return self
    }
    
    /// 解包
    /// - Parameters:
    ///   - transform: 转换解包后的值
    ///   - defaultValue: 默认值
    /// - Returns: 转换后的值
    func unwrap<T>(_ transform: (Wrapped) throws -> T, or fallback: @autoclosure () -> T) rethrows -> T {
        guard let self else {
            return fallback()
        }
        return try transform(self)
    }
    
    /// 解包
    /// - Parameters:
    ///   - defaultValue: 默认值
    ///   - transform: 转换闭包
    /// - Returns: 转换后的值
    /// 注: 和上面的unwrap方法作用一样, 但是在将尾随闭包作为转换回调时可以使代码看起来更清晰. 如:
    /// let num: Int? = 0
    /// num.or("") { num in
    ///     num.string
    /// }
    func or<T>(_ fallback: @autoclosure () -> T, map transform: (Wrapped) throws -> T) rethrows -> T {
        guard let self else {
            return fallback()
        }
        return try transform(self)
    }
    
    /// 解包Optional
    /// - Parameter fallback: 解包失败使用的默认值
    /// - Returns: Wrapped Value
    func or(_ fallback: @autoclosure () -> Wrapped) -> Wrapped {
        self ?? fallback()
    }
    
    /// 从左至右连续尝试解包直到返回有效值
    func or(_ fallback: @autoclosure () -> Wrapped?) -> Wrapped? {
        self ?? fallback()
    }
}

extension Optional where Wrapped: Sequence & ExpressibleByArrayLiteral {
    var orEmpty: Wrapped {
        or(.empty)
    }
}
