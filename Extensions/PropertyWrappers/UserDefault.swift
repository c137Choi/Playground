//
//  UserDefault.swift
//  KnowLED
//
//  Created by Choi on 2026/3/3.
//

import Foundation

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
