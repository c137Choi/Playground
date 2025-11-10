//
//  BidirectionalDictionary.swift
//  KnowLED
//
//  Created by Choi on 2025/11/8.
//

import Foundation

struct BidirectionalDictionary<Key, Value> where Key: Hashable, Value: Hashable {
    /// Key -> Value
    private(set) var keyToValue: [Key: Value] = [:]
    /// Value -> Key
    private(set) var valueToKey: [Value: Key] = [:]
    
    init() {}
    
    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        let valuesAndKeys = keysAndValues.map { key, value in
            (value, key)
        }
        self.keyToValue = Dictionary(uniqueKeysWithValues: keysAndValues)
        self.valueToKey = Dictionary(uniqueKeysWithValues: valuesAndKeys)
    }
    
    mutating func setValue(_ value: Value, forKey key: Key) {
        removeValue(forKey: key)
        keyToValue[key] = value
        valueToKey[value] = key
    }
    
    mutating func removeAll() {
        keyToValue.removeAll()
        valueToKey.removeAll()
    }
    
    mutating func removeValue(forKey key: Key) {
        if let value = keyToValue[key] {
            keyToValue[key] = nil
            valueToKey[value] = nil
        }
    }
    
    mutating func removeKey(forValue value: Value) {
        if let key = valueToKey[value] {
            keyToValue[key] = nil
            valueToKey[value] = nil
        }
    }
    
    func value(forKey key: Key) -> Value? {
        keyToValue[key]
    }
    
    func key(forValue value: Value) -> Key? {
        valueToKey[value]
    }
    
    var count: Int {
        keyToValue.count
    }
    
    var keys: Dictionary<Key, Value>.Keys {
        keyToValue.keys
    }
    
    var values: Dictionary<Key, Value>.Values {
        keyToValue.values
    }
    
    subscript(key key: Key) -> Value? {
        get {
            value(forKey: key)
        }
        set {
            if let newValue {
                setValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
}

extension BidirectionalDictionary: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
}
