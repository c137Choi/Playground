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
    
    /// 移除一组Key
    /// - Parameters:
    ///   - keysToRemove: 要移除的Keys
    ///   - liveUpdate: 是否实时更新(如果传入false, 则会在临时变量更新之后再更新自身的值)
    mutating func removeKeys<S>(_ keysToRemove: S, liveUpdate: Bool = true) where S: Sequence, S.Element == Key {
        /// 取交集以节省开销
        let intersectionKeys = self.keys.set.intersection(keysToRemove)
        /// 更新字典
        func removingKeys(_ dict: inout Self) {
            for key in intersectionKeys {
                dict.removeValue(forKey: key)
            }
        }
        /// 根据条件执行逻辑
        if liveUpdate {
            removingKeys(&self)
        } else {
            var dict = self
            removingKeys(&dict)
            self = dict
        }
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
