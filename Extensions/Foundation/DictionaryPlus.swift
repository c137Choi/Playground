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
    
    /// 下标支持Optional<Key>类型
    subscript(key: Key?) -> Value? {
        get {
            key.flatMap {
                self[$0]
            }
        }
        set {
            if let key {
                self[key] = newValue
            }
        }
    }
}
