//
//  Configurable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

public protocol SimpleInitializer {
    init()
}

public protocol Configurable {
    @discardableResult
    mutating func configure(_ configurator: (inout Self) -> Void) -> Self
}

public protocol ClassConfigurable: AnyObject {}
public protocol ClassNewInstanceConfigurable: SimpleClassConfigurable {}

/// 协议组合
public typealias SimpleConfigurable = SimpleInitializer & Configurable
public typealias SimpleClassConfigurable = SimpleInitializer & ClassConfigurable

public protocol InstanceFactory {
    static func make(_ configurator: (inout Self) -> Void) -> Self
}

extension Configurable {
    @discardableResult
    mutating func configure(_ configurator: (inout Self) -> Void) -> Self {
        configurator(&self)
        return self
    }
}

extension InstanceFactory where Self: SimpleConfigurable {
    static func make(_ configurator: (inout Self) -> Void) -> Self {
        var retval = Self()
        return retval.configure(configurator)
    }
}

extension ClassConfigurable {
    @discardableResult
    func configure(_ configurator: (Self) throws -> Void) rethrows -> Self {
        try configurator(self)
        return self
    }
}

extension ClassNewInstanceConfigurable {
    static func make(_ configurator: (Self) -> Void) -> Self {
        let retval = Self()
        return retval.configure(configurator)
    }
}

extension NSObject: ClassNewInstanceConfigurable {}
extension NSObject: SimpleInitializer {}
