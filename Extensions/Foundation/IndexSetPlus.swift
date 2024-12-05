//
//  IndexSetPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/4/1.
//

import Foundation

extension IndexSet: @retroactive ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.init(integer: value)
    }
}
