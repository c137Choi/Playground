//
//  UserDefaultsPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/8/28.
//

import Foundation

extension UserDefaults {
    
    /// 尝试将object转换, 转换失败则返回空
    static func maybeInt(forKey key: String) -> Int? {
        object(forKey: key) as? Int
    }
    
    /// 尝试将object转换, 转换失败则返回空
    static func maybeDouble(forKey key: String) -> Double? {
        object(forKey: key) as? Double
    }
    
    /// 尝试将object转换, 转换失败则返回空
    static func maybeBool(forKey key: String) -> Bool? {
        object(forKey: key) as? Bool
    }
    
    static func integer(forKey key: String) -> Int {
        standard.integer(forKey: key)
    }
    
    static func string(forKey key: String) -> String? {
        standard.string(forKey: key)
    }
    
    static func bool(forKey key: String) -> Bool {
        standard.bool(forKey: key)
    }
    
    static func set(_ value: Any?, forKey key: String) {
        standard.set(value, forKey: key)
    }
    
    static func object(forKey key: String) -> Any? {
        standard.object(forKey: key)
    }
}
