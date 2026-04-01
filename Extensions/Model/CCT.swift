//
//  CCT.swift
//  KnowLED
//
//  Created by Choi on 2026/3/27.
//

import UIKit

/// 色温+红绿
struct CCT {
    /// 色温
    var temperature: Double
    /// 红绿补偿偏移(范围: 0...1)
    var normalizedGM: Double?
}
extension CCT: Hashable {}
extension CCT: Configurable {}
extension CCT {
    
    var rgb: RGB {
        RGB(temperature: temperature, normalizedGM: normalizedGM)
    }
}

