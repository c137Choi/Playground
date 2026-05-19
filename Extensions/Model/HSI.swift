//
//  HSI.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

struct HSI: Hashable {
    /// 范围0-1
    @Clampped(range: Double.percentRange) var hue = Double.zero
    /// 范围0-1
    @Clampped(range: Double.percentRange) var saturation = Double.zero
    /// 范围0-1
    @Clampped(range: Double.percentRange) var brightness = Double.zero
}

extension HSI: Configurable {}
extension HSI {
    
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
    
    init(_ rgb: RGB) {
        self = rgb.uiColor.hsi
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
