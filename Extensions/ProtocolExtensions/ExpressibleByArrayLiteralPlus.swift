//
//  ExpressibleByArrayLiteralPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/6/3.
//

extension ExpressibleByArrayLiteral {
    
    static var empty: Self {
        []
    }
}

extension Optional where Wrapped: ExpressibleByArrayLiteral {
    
    var orEmpty: Wrapped {
        self ?? Wrapped.empty
    }
}
