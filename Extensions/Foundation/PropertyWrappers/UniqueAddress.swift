//
//  UniqueAddress.swift
//  KnowLED
//
//  Created by Choi on 2025/9/8.
//

/// https://github.com/atrick/swift-evolution/blob/diagnose-implicit-raw-bitwise/proposals/nnnn-implicit-raw-bitwise-conversion.md#associated-object-string-keys
@propertyWrapper
public class UniqueAddress {
    public init() {}
    public var wrappedValue: UnsafeRawPointer {
        UnsafeRawPointer(self.pointer)
    }
}
