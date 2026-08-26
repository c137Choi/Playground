//
//  HSI.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

nonisolated struct HSI: Codable {
    /// 范围0-1
    var hue = Double.zero
    /// 范围0-1
    var saturation = Double.zero
    /// 范围0-1
    var brightness = Double.zero
}

nonisolated extension HSI: Hashable {}
nonisolated extension HSI: Configurable {}
nonisolated extension HSI {
    
    static let zero = HSI(hue: 0, saturation: 0, brightness: 0)
    
    init?(_ uiColor: UIColor) {
        var hue = CGFloat.zero
        var saturation = CGFloat.zero
        var brightness = CGFloat.zero
        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil) {
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
        } else {
            return nil
        }
    }
    
    init(red: Double, green: Double, blue: Double) {
        let rgb = RGB(red: red, green: green, blue: blue)
        self.init(rgb)
    }
    
    init(cyan: Double, magenta: Double, yellow: Double) {
        let cmy = CMY(cyan: cyan, magenta: magenta, yellow: yellow)
        self.init(cmy.rgb)
    }
    
    /// 通过数学公式直接从RGB计算HSI(此处与UIColor一致采用HSV语义: brightness = max(r,g,b))
    /// 替代原先经由UIColor中转的转换, 提升精度与性能
    init(_ rgb: RGB) {
        let r = rgb.red
        let g = rgb.green
        let b = rgb.blue
        let maxVal = Swift.max(r, g, b)
        let minVal = Swift.min(r, g, b)
        let delta = maxVal - minVal
        self.brightness = maxVal
        self.saturation = maxVal == 0 ? 0 : delta / maxVal
        if delta == 0 {
            self.hue = 0
        } else if maxVal == r {
            var h = (g - b) / delta
            if h < 0 { h += 6 }
            self.hue = h / 6
        } else if maxVal == g {
            self.hue = ((b - r) / delta + 2) / 6
        } else {
            self.hue = ((r - g) / delta + 4) / 6
        }
    }
    
    var uiColor: UIColor {
        UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    var rgb: RGB {
        RGB(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    /// 将色相转换成RGB
    var hueToRGB: RGB {
        RGB(hue: hue, saturation: 1.0, brightness: 1.0)
    }
    
    /// 亮度设置成最大后转换成RGB
    var maxBrightnessRGB: RGB {
        RGB(hue: hue, saturation: saturation, brightness: 1.0)
    }
}
