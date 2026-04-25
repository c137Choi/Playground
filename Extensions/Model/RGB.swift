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
    
    init(red: Double, green: Double, blue: Double) {
        self.red = max(0.0, min(1.0, red))
        self.green = max(0.0, min(1.0, green))
        self.blue = max(0.0, min(1.0, blue))
    }
}

extension RGB {
    /// 黑
    static let black = RGB(red: 0, green: 0, blue: 0)
    /// 白
    static let white = RGB(red: 1, green: 1, blue: 1)
    /// 冷白
    static let coolWhite = RGB(temperature: 10000.0)
    /// 暖白
    static let warmWhite = RGB(temperature: 2000.0)
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
    /// 琥珀色
    static let amber = RGB(bitRed: 0xFF, bitGreen: 0xBF, bitBlue: 0)
    /// 浅青柠色
    static let lightLime = RGB(bitRed: 0xBF, bitGreen: 0xFF, bitBlue: 0)
    
    init(bitRed: UInt8, bitGreen: UInt8, bitBlue: UInt8) {
        self.init(red: bitRed.double / 255.0, green: bitGreen.double / 255.0, blue: bitBlue.double / 255.0)
    }
    
    init(cct: CCT) {
        self.init(temperature: cct.temperature, normalizedGM: cct.normalizedGM)
    }
    
    /// https://github.com/davidf2281/ColorTempToRGB
    /// https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
    init(temperature: Double, normalizedGM: Double? = nil) {
        let range = UInt8.range.doubleRange
        let percentKelvin = temperature / 100.0
        let red = range << (percentKelvin <= 66 ? 255 : (329.698727446 * pow(percentKelvin - 60, -0.1332047592)))
        let green = range << (percentKelvin <= 66 ? (99.4708025861 * log(percentKelvin) - 161.1195681661) : 288.1221695283 * pow(percentKelvin - 60, -0.0755148492))
        let blue = range << (percentKelvin >= 66 ? 255 : (percentKelvin <= 19 ? 0 : 138.5177312231 * log(percentKelvin - 10) - 305.0447927307))
        let normalizedRed = range.percentage(red)
        let normalizedGreen = range.percentage(green)
        let normalizedBlue = range.percentage(blue)
        self.red = normalizedRed
        self.green = normalizedGreen
        self.blue = normalizedBlue
        let gmShift = normalizedGM.map(\.percentClip.shift)
        self.setGmShift(gmShift)
    }
    
    init(hue: Double, saturation: Double, brightness: Double) {
        let hPrime = Int(hue * 6.0)
        let f = hue * 6.0 - hPrime.double
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - f * saturation)
        let t = brightness * (1 - (1 - f) * saturation)
        switch hPrime % 6 {
        case 0:
            self.red = brightness
            self.green = t
            self.blue = p
        case 1:
            self.red = q
            self.green = brightness
            self.blue = p
        case 2:
            self.red = p
            self.green = brightness
            self.blue = t
        case 3:
            self.red = p
            self.green = q
            self.blue = brightness
        case 4:
            self.red = t
            self.green = p
            self.blue = brightness
        default:
            self.red = brightness
            self.green = p
            self.blue = q
        }
    }
    
    init(x: Double, y: Double) {
        self = ColorSpace.adobeRGB.rgb(x: x, y: y)
    }
    
    mutating func blend(_ another: RGB) {
        self.red = min(1.0, red + another.red)
        self.green = min(1.0, green + another.green)
        self.blue = min(1.0, blue + another.blue)
    }
    
    func blending(_ another: RGB) -> RGB {
        var copy = self
        copy.blend(another)
        return copy
    }
    
    /// 设置红绿补偿
    /// - Parameter gmShift: 范围(-1...1)
    mutating func setGmShift(_ gmShift: Double?) {
        guard let gmShift else { return }
        GMCorrectionMatrix(gmShift: gmShift).apply(to: &self)
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
    
    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension RGB {
    
    static func + (lhs: RGB, rhs: RGB) -> RGB {
        lhs.blending(rhs)
    }
    
    static func * (lhs: RGB, rhs: Double) -> RGB {
        let percentage = Double.percentRange << rhs
        return RGB(red: lhs.red * percentage, green: lhs.green * percentage, blue: lhs.blue * percentage)
    }
}

struct GMCorrectionMatrix {
    let m11: Double  // Red → Red
    let m12: Double  // Green → Red
    let m13: Double  // Blue → Red
    
    let m21: Double  // Red → Green
    let m22: Double  // Green → Green
    let m23: Double  // Blue → Green
    
    let m31: Double  // Red → Blue
    let m32: Double  // Green → Blue
    let m33: Double  // Blue → Blue
    
    /// 初始化
    /// - Parameter normalizedGM: 范围(-1...1)
    init(gmShift: Double) {
        let t = max(-1.0, min(1.0, gmShift))
        
        // Green shift (t > 0): increase green, decrease red and blue
        // Magenta shift (t < 0): increase red and blue, decrease green
        
        let greenBoost = t * 0.30        // Green channel boost/reduction
        let complementaryAtten = abs(t) * 0.25  // Reduction of complementary channels
        
        if t >= 0 {
            // +Green: Boost green, attenuate red and blue
            self.m11 = 1.0 - complementaryAtten   // Red → Red (reduced)
            self.m12 = 0.0                       // Green → Red
            self.m13 = 0.0                       // Blue → Red
            
            self.m21 = 0.0                       // Red → Green
            self.m22 = 1.0 + greenBoost          // Green → Green (boosted)
            self.m23 = 0.0                       // Blue → Green
            
            self.m31 = 0.0                       // Red → Blue
            self.m32 = 0.0                       // Green → Blue
            self.m33 = 1.0 - complementaryAtten    // Blue → Blue (reduced)
        } else {
            // +Magenta: Boost red and blue, attenuate green
            self.m11 = 1.0 + complementaryAtten   // Red → Red (boosted)
            self.m12 = 0.0                       // Green → Red
            self.m13 = 0.0                       // Blue → Red
            
            self.m21 = 0.0                       // Red → Green
            self.m22 = 1.0 + greenBoost          // Green → Green (reduced, so boost is negative)
            self.m23 = 0.0                       // Blue → Green
            
            self.m31 = 0.0                       // Red → Blue
            self.m32 = 0.0                       // Green → Blue
            self.m33 = 1.0 + complementaryAtten    // Blue → Blue (boosted)
        }
    }
    
    func apply(to rgb: inout RGB) {
        let red = m11 * rgb.red + m12 * rgb.green + m13 * rgb.blue
        let green = m21 * rgb.red + m22 * rgb.green + m23 * rgb.blue
        let blue = m31 * rgb.red + m32 * rgb.green + m33 * rgb.blue
        rgb.red = red
        rgb.green = green
        rgb.blue = blue
    }
}
