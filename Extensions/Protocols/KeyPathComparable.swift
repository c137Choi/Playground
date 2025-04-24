//
//  KeyPathComparable.swift
//  KnowLED
//
//  Created by Choi on 2025/4/24.
//

import Foundation

protocol KeyPathComparable: Equatable {
    /// 实例方法，比较两个对象的指定属性是否相等
    func isEqual(to other: Self, by keyPaths: [PartialKeyPath<Self>]) -> Bool
}

extension KeyPathComparable {
    /// 默认实现
    func isEqual(to other: Self, by keyPaths: [PartialKeyPath<Self>]) -> Bool {
        keyPaths.allSatisfy { keyPath in
            // 使用 Mirror 反射来比较属性值
            let mirror1 = Mirror(reflecting: self)
            let mirror2 = Mirror(reflecting: other)
            
            // 获取属性名称
            guard let propertyName = getPropertyName(for: keyPath) else { return false }
            
            // 查找并比较属性值
            if let value1 = mirror1.descendant(propertyName), let value2 = mirror2.descendant(propertyName) {
                return isEqual(value1, value2)
            }
            return false
        }
    }
    
    private func getPropertyName(for keyPath: PartialKeyPath<Self>) -> String? {
        // 这里简化处理，实际项目中可能需要更复杂的逻辑来获取属性名
        return "\(keyPath)".components(separatedBy: ".").last
    }
    
    private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        // 处理 Optional 类型
        if let lhs = lhs as? AnyOptional, let rhs = rhs as? AnyOptional {
            return lhs.isEqual(to: rhs)
        }
        
        // 处理 Equatable 类型
        guard let lhs = lhs as? any Equatable, let rhs = rhs as? any Equatable else {
            return false
        }
        
        return lhs.isEqual(to: rhs)
    }
}

// 用于处理 Optional 类型的辅助协议
fileprivate protocol AnyOptional {
    func isEqual(to other: AnyOptional) -> Bool
}

extension Optional: AnyOptional where Wrapped: Equatable {
    fileprivate func isEqual(to other: AnyOptional) -> Bool {
        guard let other = other as? Optional<Wrapped> else { return false }
        return self == other
    }
}

// Equatable 扩展，用于类型擦除比较
extension Equatable {
    fileprivate func isEqual(to other: any Equatable) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
