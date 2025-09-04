//
//  Choi.swift
//
//  Created by Choi on 2025/9/4.
//

import Foundation

public struct Choi<Base> {
    /// Base对象
    public let base: Base
    /// 初始化
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ChoiCompatible {
    associatedtype Base

    static var O: Choi<Base>.Type { get set }

    var OO: Choi<Base> { get set }
}

extension NSObject: ChoiCompatible {}

extension ChoiCompatible {
    
    public static var O: Choi<Self>.Type {
        get {
            Choi<Self>.self
        }
        // this enables using Reactive to "mutate" base type
        // swiftlint:disable:next unused_setter_value
        set {}
    }

    public var OO: Choi<Self> {
        get {
            Choi(self)
        }
        // this enables using Reactive to "mutate" base object
        // swiftlint:disable:next unused_setter_value
        set {}
    }
}
