//
//  CMY.swift
//  KnowLED
//
//  Created by Choi on 2026/5/18.
//

struct CMY {
    /// 0...1.0
    var cyan = Double.zero
    /// 0...1.0
    var magenta = Double.zero
    /// 0...1.0
    var yellow = Double.zero
}
extension CMY: Codable {}
extension CMY {
    
    init(rgb: RGB) {
        self.init(cyan: 1.0 - rgb.red, magenta: 1.0 - rgb.green, yellow: 1.0 - rgb.blue)
    }
    
    var rgb: RGB {
        RGB(cmy: self)
    }
}
