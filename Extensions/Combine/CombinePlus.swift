//
//  CombinePlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2022/5/30.
//  Copyright © 2022 Choi. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Output: OptionalConvertible {
    var unwrapped: AnyPublisher<Output.Wrapped, Failure> {
        compactMap(\.optionalValue).eraseToAnyPublisher()
    }
}
