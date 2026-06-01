//
//  AnyFormatStyle.swift
//  KnowLED
//
//  Created by Choi on 2026/6/1.
//

import Foundation

struct AnyFormatStyle: Sendable {
    
    private let format: @Sendable (Double) -> String
    
    init(format: @Sendable @escaping (Double) -> String) {
        self.format = format
    }
    
    init<F: FormatStyle>(_ style: F) where F.FormatInput == Double, F.FormatOutput == String {
        self.format = { input in
            style.format(input)
        }
    }
    
    func format(_ value: Double) -> String {
        format(value)
    }
}
