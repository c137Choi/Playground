//
//  OptionalType.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

protocol OptionalType<Wrapped> {
    associatedtype Wrapped
    var optionalValue: Wrapped? { get }
}

extension Optional: OptionalType {
    var optionalValue: Wrapped? { self }
}
