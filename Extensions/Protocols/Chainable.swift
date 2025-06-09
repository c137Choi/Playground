//
//  Chainable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

@dynamicMemberLookup
fileprivate struct Configurator<Object> {
    
    var stabilized: Object { target }
    
    private let target: Object
    
    init(_ target: Object) {
        self.target = target
    }
    
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Configurator<Object> {
        { value in
            target[keyPath: keyPath] = value
            return self
        }
    }
    
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Void where Object: AnyObject {
        setter(for: target, keyPath: keyPath)
    }
    
    func stabilize(_ configure: (Object) -> Void) -> Object {
        configure(target)
        return self.stabilized
    }
}

fileprivate protocol Chainable {}

extension Chainable {
    fileprivate var set: Configurator<Self> {
        Configurator(self)
    }
}

extension Chainable where Self: SimpleInitializer {
    fileprivate static var make: Configurator<Self> {
        self.init().set
    }
}
