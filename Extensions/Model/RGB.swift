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
    /// 黑
    static let black = RGB(red: 0, green: 0, blue: 0)
    /// 白
    static let white = RGB(red: 1, green: 1, blue: 1)
    /// 红
    static let red = RGB(red: 1, green: 0, blue: 0)
    /// 绿
    static let green = RGB(red: 0, green: 1, blue: 0)
    /// 蓝
    static let blue = RGB(red: 0, green: 0, blue: 1)
    /// 青(绿蓝Max)
    static let cyan = RGB(red: 0, green: 1, blue: 1)
    /// 品(红蓝Max)
    static let magenta = RGB(red: 1, green: 0, blue: 1)
    /// 黄(红绿Max)
    static let yellow = RGB(red: 1, green: 1, blue: 0)
    /// 琥珀色(红Max + 绿0.7490)
    static let amber = RGB(red: 1, green: 0xBF.double / 255.0, blue: 0)
    /// 浅青柠色(红0.7490 + 绿Max)
    static let lightLime = RGB(red: 0xBF.double / 255.0, green: 1.0, blue: 0.0)

    /// https://github.com/davidf2281/ColorTempToRGB
    /// https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
    init(temperature: Double) {
        let range = UInt8.range.doubleRange
        let percentKelvin = temperature / 100.0
        let red = range << (percentKelvin <= 66 ? 255 : (329.698727446 * pow(percentKelvin - 60, -0.1332047592)))
        let green = range << (percentKelvin <= 66 ? (99.4708025861 * log(percentKelvin) - 161.1195681661) : 288.1221695283 * pow(percentKelvin - 60, -0.0755148492))
        let blue = range << (percentKelvin >= 66 ? 255 : (percentKelvin <= 19 ? 0 : 138.5177312231 * log(percentKelvin - 10) - 305.0447927307))
        self.red = range.progress(red)
        self.green = range.progress(green)
        self.blue = range.progress(blue)
    }
    
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
