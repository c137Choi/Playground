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
    
    /// 移除键值对并返回新字典
    /// - Parameter keysToRemove: 要移除的键
    /// - Returns: 移除键值后的新字典
    func removingKeys<S>(_ keysToRemove: S) -> Self where S: Sequence, S.Element == Key {
        var dictionary = self
        dictionary.removeKeys(keysToRemove)
        return dictionary
    }
    
    /// 移除一组Key
    /// - Parameters:
    ///   - keysToRemove: 要移除的Keys
    mutating func removeKeys<S>(_ keysToRemove: S) where S: Sequence, S.Element == Key {
        var dictionary = self
        for key in self.keys.set.intersection(keysToRemove) {
            dictionary[key] = nil
        }
        self = dictionary
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
