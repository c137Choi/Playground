//
//  AnyFormatStyle.swift
//  KnowLED
//
//  Created by Choi on 2026/6/1.
//

import Foundation

nonisolated struct AnyFormatStyle<FormatInput, FormatOutput>: Sendable {

    private let format: @Sendable (FormatInput) -> FormatOutput

    init(format: @Sendable @escaping (FormatInput) -> FormatOutput) {
        self.format = format
    }
    
    init<F: Sendable>(_ style: F) where F: FormatStyle, FormatInput == F.FormatInput, FormatOutput == F.FormatOutput {
        format = {
            style.format($0)
        }
    }

    func format(_ value: FormatInput) -> FormatOutput {
        format(value)
    }
}
