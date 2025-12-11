//
//  MTLClearColorPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/3/31.
//

import Metal
import MetalKit

extension MTLClearColor: @retroactive ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        guard let rgba = value.rgba else {
            fatalError("Illegal color")
        }
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: 1.0)
    }
}
