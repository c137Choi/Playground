//
//  MTLClearColorPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/3/31.
//

import Metal
import MetalKit

extension MTLClearColor: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        guard let argb = value.aRGB else {
            fatalError("Illegal color")
        }
        self.init(red: argb.red, green: argb.green, blue: argb.blue, alpha: 1.0)
    }
}
