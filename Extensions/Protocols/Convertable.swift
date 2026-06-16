//
//  Convertable.swift
//  KnowLED
//
//  Created by Choi on 2024/9/29.
//

import Foundation

public protocol Convertable {
    func `as`<T>(_ type: T.Type) -> T?
}

nonisolated extension Convertable {
    public func `as`<T>(_ type: T.Type) -> T? {
        self as? T
    }
}

nonisolated extension NSObject: Convertable {}
nonisolated extension Optional: Convertable {}

nonisolated extension Error {
    public func `as`<T>(_ type: T.Type) -> T? {
        self as? T
    }
}
