//
//  OptionalConvertible.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

protocol OptionalConvertible {
    associatedtype Wrapped
    var optionalValue: Wrapped? { get }
}

extension OptionalConvertible {
    var optionalValue: Self? { self }
}

extension NSObject: OptionalConvertible {}
extension Optional: OptionalConvertible {
    var optionalValue: Self { self }
}
