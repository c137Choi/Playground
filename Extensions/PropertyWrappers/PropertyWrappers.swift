//
//  PropertyWrappers.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/7/9.
//  Copyright © 2021 Choi. All rights reserved.
//

import Foundation
import UIKit

@propertyWrapper
struct Clampped<T: Comparable> {
    
    let range: ClosedRange<T>
    
    private var innerValue: T
    
    init(wrappedValue: T, range: ClosedRange<T>) {
        self.range = range
        self.innerValue = range << wrappedValue
    }
    
    var wrappedValue: T {
        get { innerValue }
        set { innerValue = range << newValue }
    }
}
extension Clampped: Sendable where T: Sendable {}
extension Clampped: Equatable where T: Equatable {}
extension Clampped: Hashable where T: Hashable {}
extension Clampped: Codable where T: Codable {}

/// 让值在某个范围内循环
@propertyWrapper
nonisolated class CycledValue<T: Comparable> {

    fileprivate var innerValue: T
    fileprivate let range: ClosedRange<T>
    init(wrappedValue: T, range: ClosedRange<T>) {
        self.range = range
        self.innerValue = range << wrappedValue
    }
    
    var wrappedValue: T {
        get { innerValue }
        set {
            switch newValue {
            case ..<range.lowerBound:
                /// 小于最小值则设置成最大值
                innerValue = range.upperBound
            case range:
                /// 正常赋值
                innerValue = newValue
            default:
                /// 大于最大值则设置成最小值
                innerValue = range.lowerBound
            }
        }
    }
    
    fileprivate var upperBound: T {
        range.upperBound
    }
    
    fileprivate var lowerBound: T {
        range.lowerBound
    }
    
    static func += (lhs: CycledValue<T>, rhs: T) where T: FixedWidthInteger {
        let adding = lhs.wrappedValue.addingReportingOverflow(rhs)
        if adding.overflow {
            lhs.wrappedValue = lhs.range.lowerBound
        } else {
            lhs.wrappedValue = adding.partialValue
        }
    }
    
    static func -= (lhs: CycledValue<T>, rhs: T) where T: FixedWidthInteger {
        let subtracting = lhs.wrappedValue.subtractingReportingOverflow(rhs)
        if subtracting.overflow {
            lhs.wrappedValue = lhs.range.upperBound
        } else {
            lhs.wrappedValue = subtracting.partialValue
        }
    }
}

@propertyWrapper
nonisolated final class CycledNumber<T: FloatingPoint>: CycledValue<T> {
    
    /// 超出范围时是否带上溢出值. 例如: 3.0...5.0
    /// 设置成6.0的时候, 最终值为4.0(溢出1.0, 最小值加1.0)
    /// 设置成2.0的时候, 最终值为4.0(溢出1.0, 最高值减1.0)
    let overflow: Bool
    
    /// 初始化方法
    /// - Parameters:
    ///   - wrappedValue: 初始值
    ///   - range: 范围
    ///   - overflow: 是否处理溢出值
    ///   注: 初始化时使用父类方法(即: 不处理溢出值, 只限制在范围内)
    init(wrappedValue: T, range: ClosedRange<T>, overflow: Bool = false) {
        self.overflow = overflow
        super.init(wrappedValue: wrappedValue, range: range)
    }
    
    override var wrappedValue: T {
        get { super.wrappedValue }
        set {
            if overflow {
                let distance = upperBound - lowerBound
                do throws(ClosedRangeBoundError) {
                    super.wrappedValue = try range.constrainedResult(newValue).get()
                } catch {
                    switch error {
                    case .tooLow:
                        let overflow = lowerBound - newValue
                        let remainder = overflow.truncatingRemainder(dividingBy: distance)
                        super.wrappedValue = upperBound - remainder
                    case .tooHigh:
                        let overflow = newValue - upperBound
                        let remainder = overflow.truncatingRemainder(dividingBy: distance)
                        super.wrappedValue = lowerBound + remainder
                    }
                }
            } else {
                super.wrappedValue = newValue
            }
        }
    }
    
    static func += (lhs: CycledNumber<T>, rhs: T) {
        lhs.wrappedValue = lhs.wrappedValue + rhs
    }
    
    static func -= (lhs: CycledNumber<T>, rhs: T) {
        lhs.wrappedValue = lhs.wrappedValue - rhs
    }
}

@propertyWrapper
struct UserDefault<T> {
    private let defaultValue: T
    private let key: String
    private let storage: UserDefaults
    
    init(key: String, storage: UserDefaults = .standard, defaultValue: T) {
        self.defaultValue = defaultValue
        self.key = key
        self.storage = storage
        if storage.object(forKey: key).isVoid {
            storage.set(defaultValue, forKey: key)
        }
    }
    
    var wrappedValue: T {
        get {
            storage.object(forKey: key).as(T.self) ?? defaultValue
        }
        set {
            storage.set(newValue, forKey: key)
        }
    }
}
