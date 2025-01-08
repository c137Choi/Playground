//
//  DictionaryPlus.swift
//
//  Created by Choi on 2022/10/21.
//

import Foundation

extension Dictionary {
    
    func valueForKey(_ key: Key) -> Value? {
        self[key]
    }
    
    /// 替换键
    /// - Parameters:
    ///   - oldKey: 旧键
    ///   - newKey: 新键
    mutating func replace(oldKey: Key, with newKey: Key) {
        /// 无对应的旧值则直接返回
        guard let value = removeValue(forKey: oldKey) else { return }
        /// 使用新键保存旧值
        updateValue(value, forKey: newKey)
    }
}

// MARK: - Optional Value Dictionary
extension Dictionary where Value: OptionalType {
    var unwrapped: Dictionary<Key, Value.Wrapped> {
        reduce(into: [Key:Value.Wrapped]()) { partialResult, tuple in
            guard let value = tuple.value.optionalValue else { return }
            partialResult[tuple.key] = value
        }
    }
}
