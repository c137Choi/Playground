//
//  RGB.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import CoreGraphics

struct RGB {
    /// 0...1.0
    var red: Double
    /// 0...1.0
    var green: Double
    /// 0...1.0
    var blue: Double
}

extension RGB {
    
    /// 最大亮度
    var maxBrightness: Double {
        max(red, green, blue)
    }
    
    /// 加权亮度（最常用，人眼感知）
    var weightedBrightness: Double {
        Double.percentRange << (0.2126 * red + 0.7152 * green + 0.0722 * blue)
    }
    
    /// 平均亮度
    var averageBrightness: Double {
        (red + green + blue) / 3.0
    }
}
