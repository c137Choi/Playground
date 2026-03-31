//
//  HSI.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import CoreGraphics

struct HSI: Hashable {
    
    /// 范围0-1
    var hue: Double
    /// 范围0-1
    var saturation: Double
    /// 范围0-1
    var brightness: Double
    
    var rgb: RGB {
        RGB(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    /// 将色相转换成RGB
    var hueToRGB: RGB {
        RGB(hue: hue, saturation: 1.0, brightness: 1.0)
    }
}
