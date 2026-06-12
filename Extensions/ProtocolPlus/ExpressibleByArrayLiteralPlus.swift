//
//  ExpressibleByArrayLiteralPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/6/3.
//

extension ExpressibleByArrayLiteral {
    
    nonisolated static var empty: Self {
        []
    }
}

extension Optional where Wrapped: ExpressibleByArrayLiteral {
    
    nonisolated var orEmpty: Wrapped {
        self ?? Wrapped.empty
    }
}
