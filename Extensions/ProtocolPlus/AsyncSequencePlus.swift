//
//  AsyncSequencePlus.swift
//  KnowLED
//
//  Created by Choi on 2024/10/16.
//

import Foundation

nonisolated extension AsyncSequence {
    
    /// 来源: https://www.hackingwithswift.com/quick-start/concurrency/how-to-convert-an-asyncsequence-into-a-sequence
    /// Tip: Because we’ve made collect() use rethrows, you only need to call it using try if the call to reduce() would normally throw, so if you have an async sequence that doesn’t throw errors you can skip try entirely.
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element].empty) { array, element in
            array.append(element)
        }
    }
}

nonisolated extension AsyncSequence where Element: OptionalConvertible {
    
    func collect() async rethrows -> [Element.Wrapped] where Element: OptionalConvertible {
        try await reduce(into: [Element.Wrapped].empty) { array, element in
            guard let unwrapped = element.optionalValue else { return }
            array.append(unwrapped)
        }
    }
}
