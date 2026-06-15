//
//  OptionalConvertible.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

nonisolated protocol OptionalConvertible {
    associatedtype Wrapped
    var optionalValue: Wrapped? { get }
}

nonisolated extension OptionalConvertible {
    var optionalValue: Self? { self }
}

nonisolated extension NSObject: OptionalConvertible {}
nonisolated extension Optional: OptionalConvertible {
    var optionalValue: Self { self }
}
