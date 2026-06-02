//
//  AnyFormatStyle.swift
//  KnowLED
//
//  Created by Choi on 2026/6/1.
//

import Foundation

struct AnyFormatStyle<Input, Output>: Sendable {
    
    private let format: @Sendable (Input) -> Output
    
    init(format: @Sendable @escaping (Input) -> Output) {
        self.format = format
    }
    
    init<F>(_ style: F) where F: FormatStyle, Input == F.FormatInput, Output == F.FormatOutput {
        format = {
            style.format($0)
        }
    }
    
    func format(_ value: Input) -> Output {
        format(value)
    }
}
