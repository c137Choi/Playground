//
//  RGBA.swift
//  KnowLED
//
//  Created by Choi on 2026/3/27.
//

nonisolated struct RGBA {
    var red = Double.zero
    var green = Double.zero
    var blue = Double.zero
    var alpha = Double.zero
}

nonisolated extension RGBA {
    /// 纯白
    static let white = RGBA(red: 1, green: 1, blue: 1, alpha: 1)
    /// 全0
    static let zero = RGBA(red: 0, green: 0, blue: 0, alpha: 0)
    
    init?(_ uiColor: UIColor) {
        var red = CGFloat.zero
        var green = CGFloat.zero
        var blue = CGFloat.zero
        var alpha = CGFloat.zero
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        } else {
            return nil
        }
    }
    
    init(_ rgb: RGB, alpha: Double = 1.0) {
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha)
    }
    
    var rgb: RGB {
        RGB(red: red, green: green, blue: blue)
    }
    
    var rgbValue: Int {
        rawValue & 0x00_FF_FF_FF
    }
    
    var rgbArray: [Double] {
        [red, green, blue]
    }
}

nonisolated extension RGBA: RawRepresentable {
    
    var rawValue: Int {
        let intAlpha = Int(alpha * 0xFF) << 24
        let intRed = Int(red * 0xFF) << 16
        let intGreen = Int(green * 0xFF) << 8
        let intBlue = Int(blue * 0xFF)
        return intAlpha | intRed | intGreen | intBlue
    }
    
    /// 初始化
    /// - Parameter rawValue: ARGB形式的Int值
    init?(rawValue: Int) {
        let maxRGB = 0xFF_FF_FF
        let maxARGB = 0xFF_FF_FF_FF
        switch rawValue {
        case let raw where raw >= 0 && raw <= maxRGB:
            self.red   = Double((raw & 0xFF_00_00) >> 16) / 0xFF
            self.green = Double((raw & 0x00_FF_00) >>  8) / 0xFF
            self.blue  = Double( raw & 0x00_00_FF       ) / 0xFF
            self.alpha = 1.0
        case let raw where raw > maxRGB && raw <= maxARGB:
            self.alpha = Double((raw & 0xFF_00_00_00) >> 24) / 0xFF
            self.red   = Double((raw & 0x00_FF_00_00) >> 16) / 0xFF
            self.green = Double((raw & 0x00_00_FF_00) >>  8) / 0xFF
            self.blue  = Double( raw & 0x00_00_00_FF       ) / 0xFF
        default:
            return nil
        }
    }
}

nonisolated extension RGBA: Comparable {
    
    /// 比较两个颜色
    static func < (lhs: RGBA, rhs: RGBA) -> Bool {
        let lRed = lhs.red, lGreen = lhs.green, lBlue = lhs.blue
        let rRed = rhs.red, rGreen = rhs.green, rBlue = rhs.blue
        if lRed != rRed {
            return lRed < rRed
        }
        else if lGreen != rGreen {
            return lGreen < rGreen
        }
        else if lBlue != rBlue {
            return lBlue < rBlue
        }
        else {
            return false
        }
    }
}
