//
//  CCT.swift
//  KnowLED
//
//  Created by Choi on 2026/3/27.
//

import UIKit

/// 色温+红绿
struct CCT {
    var temperature: Double
    var gm: Int?
}
extension CCT: Hashable {}
extension CCT: Configurable {}
extension CCT {
    
    var uiColor: UIColor {
        UIColor(temperature: temperature)
    }
}

