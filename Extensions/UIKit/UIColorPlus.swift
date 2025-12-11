//
//  UIColorPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/11.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit
import Accelerate

extension UIColor {
    /// 冷白
    static let coldWhite = UIColor(temperature: 10_000.0)
    /// 暖白
    static let warmWhite = UIColor(temperature: 2_000.0)
}

extension UIColor {
    
    /// 返回较深的颜色
    var darker: UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, a: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &a) {
            return UIColor(red: max(red - 0.2, 0.0), green: max(green - 0.2, 0.0), blue: max(blue - 0.2, 0.0), alpha: a)
        } else {
            return self
        }
    }
    
    /// 返回颜色是否为透明
    var isClear: Bool {
        cgColor.alpha.isZero
    }
    
    var hexString: String? {
        hexString(alphaIgnored: true)
    }
    
    func hexString(alphaIgnored: Bool) -> String? {
        int(alphaIgnored: alphaIgnored).map { int in
            /// 注意这里不能使用int.hexString,因为如果碰到解析正绿色的时候,字符串会变成4位:#FF00
            int.argbColorHexString
        }
    }
    
    /// 颜色 -> 色温
    var temperature: CGFloat {
        guard let rgba else { return 0 }
        let red = rgba.red
        let green = rgba.green
        let blue = rgba.blue
        
        /// RGB -> XYZ color space
        let x = red * 0.4124 + green * 0.3576 + blue * 0.1805
        let y = red * 0.2126 + green * 0.7152 + blue * 0.0722
        let z = red * 0.0193 + green * 0.1192 + blue * 0.9505
        
        /// Calculate chromaticty coordinates
        let xc = x / (x + y + z)
        let yc = y / (x + y + z)
        
        /// Use Planck's law to calculate color temperature
        let n = (xc - 0.3320) / (0.1858 - yc)
        guard n.isNormal else { return 0 }
        return 449 * pow(n, 3) + 3525 * pow(n, 2) + 6823.3 * n + 5520.33
    }
    
    /// 返回argb颜色
    var int: Int? {
        int(alphaIgnored: true)
    }
    
    /// 返回ARGB的数值
    /// - Parameter alphaIgnored: 是否忽略透明度
    /// - Returns: 表示颜色的整型数值
    func int(alphaIgnored: Bool = true) -> Int? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        var redComponent = CGFloat.percentRange << components[0]
        var greenComponent = CGFloat.percentRange << components[1]
        var blueComponent = CGFloat.percentRange << components[2]
        /// 检查数值
        if redComponent.isNaN { redComponent = 0 }
        if greenComponent.isNaN { greenComponent = 0 }
        if blueComponent.isNaN { blueComponent = 0 }
        /// 转换成0...255的整数
        lazy var red = Int(redComponent * 255.0)
        lazy var green = Int(greenComponent * 255.0)
        lazy var blue = Int(blueComponent * 255.0)
        /// 合成RGB整数
        lazy var rgb = (red << 16) ^ (green << 8) ^ blue
        
        switch components.count {
        case 3:
            return rgb
        case 4:
            /// 透明度
            lazy var alphaPercent = CGFloat.percentRange << components[3]
            lazy var alpha = Int(alphaPercent * 255.0)
            /// 是否忽略透明通道
            return alphaIgnored ? rgb : (alpha << 24) ^ rgb
        default:
            return nil
        }
    }
    
    var hue: CGFloat {
        hsba.map(fallback: 0, \.hue)
    }
    
    var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return (h, s, b, a)
    }
    
    /// 计算色温
    var kelvin: CGFloat? {
        guard let rgba else { return nil }
        let red = rgba.red
        let green = rgba.green
        let blue = rgba.blue
        let temp = (0.23881 * red + 0.25499 * green - 0.58291 * blue) / (0.11109 * red - 0.85406 * green + 0.52289 * blue)
        let colorTemperature = 449 * pow(temp, 3) + 3525 * pow(temp, 2) + 6823.3 * temp + 5520.33
        return colorTemperature
    }
    
    var rgba: RGBA? {
        RGBA(self)
    }
    
    var xy: XY {
        rgba.flatMap(fallback: .zero, ColorSpace.adobeRGB.xyFromColor)
    }
    
    /// 转换成xy色域坐标
    fileprivate var xyLegacy: XY {
        /// 取出颜色元素
        guard let rgba else { return .zero }
        /// 求出XYZ = 向量 * 矩阵
        let XYZ = rgba.rgbArray * ColorGamut.bt2020.M
        /// XYZ求和
        let XYZSum = vDSP.sum(XYZ)
        /// 确保值正常否则返回0
        guard XYZSum.isNormal else { return .zero }
        /// 分别求出xyz
        let resultXYZ = XYZ.lazy.map {
            $0 / XYZSum
        }
        guard resultXYZ.count >= 2 else { return .zero }
        let x = resultXYZ[0]
        let y = resultXYZ[1]
        return XY(uncheckedX: x, uncheckedY: y).or(.zero)
    }
    
    /// 从色温创建颜色
    /// - Parameter cct: 色温 | 单位: 开尔文
    /// - Returns: UIColor对象
    static func fromTemperature(_ cct: CGFloat) -> UIColor {
        UIColor(temperature: cct)
    }
    
    /// 从色温创建颜色
    /// - Parameter temperature: 色温
    /// https://github.com/davidf2281/ColorTempToRGB
    /// https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
    convenience init(temperature: CGFloat) {
        let components = UIColor.componentsForColorTemperature(temperature)
        self.init(red: components.red, green: components.green, blue: components.blue, alpha: 1.0)
    }
    
    convenience init(rgba: RGBA) {
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
    
    convenience init(xy: XY) {
        self.init(x: xy.x, y: xy.y)
    }
    
    /// XY坐标创建颜色
    convenience init(x: Double, y: Double) {
        let rgba = ColorSpace.adobeRGB.color(x: x, y: y)
        self.init(rgba: rgba)
    }
    
    fileprivate convenience init(legacyX x: Double, legacyY y: Double) {
        let z = 1.0 - x - y
        
        let Y = 1.0
        let X = (Y / y) * x
        let Z = (Y / y) * z

        /// sRGB D65 CONVERSION
        var r = X  * 3.2406 - Y * 1.5372 - Z * 0.4986
        var g = -X * 0.9689 + Y * 1.8758 + Z * 0.0415
        var b = X  * 0.0557 - Y * 0.2040 + Z * 1.0570

        if r > b && r > g && r > 1.0 {
            // red is too big
            g = g / r
            b = b / r
            r = 1.0
        } else if g > b && g > r && g > 1.0 {
            // green is too big
            r = r / g
            b = b / g
            g = 1.0
        } else if b > r && b > g && b > 1.0 {
            // blue is too big
            r = r / b
            g = g / b
            b = 1.0
        }
        // Apply gamma correction
        r = r <= 0.0031308 ? 12.92 * r : (1.0 + 0.055) * pow(r, (1.0 / 2.4)) - 0.055
        g = g <= 0.0031308 ? 12.92 * g : (1.0 + 0.055) * pow(g, (1.0 / 2.4)) - 0.055
        b = b <= 0.0031308 ? 12.92 * b : (1.0 + 0.055) * pow(b, (1.0 / 2.4)) - 0.055
        if r > b && r > g {
            // red is biggest
            if (r > 1.0) {
                g = g / r
                b = b / r
                r = 1.0
            }
        } else if g > b && g > r {
            // green is biggest
            if g > 1.0 {
                r = r / g
                b = b / g
                g = 1.0
            }
        } else if b > r && b > g {
            // blue is biggest
            if b > 1.0 {
                r = r / b
                g = g / b
                b = 1.0
            }
        }
        /// 限制在0...1范围内避免出现负值导致错误
        let range = (0.0...1.0)
        var cr = range << r
        var cg = range << g
        var cb = range << b
        if cr.isNaN { cr = 0 }
        if cg.isNaN { cg = 0 }
        if cb.isNaN { cb = 0 }
        self.init(red: cr, green: cg, blue: cb, alpha: 1.0)
    }
    
    static func hue(_ hue: Double) -> UIColor {
        UIColor(hue: hue)
    }
    convenience init(hue: Double) {
        self.init(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    @available(iOS 13.0, *)
    convenience init(dark: UIColor, light: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
    
    /// 使用RGB创建UIColor | 用于某些情况下使用.map方法快速映射成UIColor
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 使用RGB创建UIColor | 用于某些情况下使用.map方法快速映射成UIColor | 用于某些情况下使用Double类型作输入参数
    convenience init(red: Double, green: Double, blue: Double) {
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 添加透明色
    static func *(lhs: UIColor, rhs: CGFloat) -> UIColor {
        lhs.withAlphaComponent(rhs)
    }
    
    static func hex(_ hexValue: Int) -> UIColor {
        hexValue.uiColor
    }
    
    /// 传入gm的百分比,转换成要混合的gm颜色和比例
    /// - Parameter gm: gm百分比
    static func gmColorWeight(_ gm: Double) -> (color: UIColor?, weight: Double?) {
        let maxMagentaWeight = 0.3
        let maxGreenWeight = 0.15
        var gmColor: UIColor?
        var gmWeight: Double?
        switch gm {
        case ..<0.5:
            let magentaPercent = 1.0 - gm / 0.5
            gmColor = .magenta
            gmWeight = magentaPercent * maxMagentaWeight
        case 0.5:
            break
        default:
            let greenPercent = (gm - 0.5) / 0.5
            gmColor = .green
            gmWeight = greenPercent * maxGreenWeight
        }
        return (gmColor, gmWeight)
    }
    
    static func blendColors(brightness: CGFloat? = nil, @ArrayBuilder<ColorBlendComponent> _ components: () -> [ColorBlendComponent]) -> UIColor {
        blendColors(components(), brightness: brightness)
    }
    
    /// 混合颜色
    /// - Parameters:
    ///   - components: 颜色元素
    ///   - brightness: 指定亮度 | 如果不指定,可能出现颜色混合后亮度太暗的问题
    /// - Returns: 混合的颜色
    static func blendColors(_ components: [ColorBlendComponent], brightness: CGFloat? = nil) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        components.forEach { component in
            if let rgba = component.color.rgba {
                red += rgba.red * component.weight
                green += rgba.green * component.weight
                blue += rgba.blue * component.weight
                alpha += rgba.alpha * component.weight
            }
        }
        if let brightness, let hsba = UIColor(red: red, green: green, blue: blue, alpha: alpha).hsba {
            return UIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: brightness, alpha: 1.0)
        } else {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    /// 色温转颜色的另外一种实现 | 暂不启用
    /// - Parameter kelvin: 色温
    /// - Returns: 色温表示的颜色
    private static func colorWithKelvin(_ kelvin: CGFloat) -> UIColor {
        let kelvinRange = 1000.0...40_000.0
        let k = kelvinRange << kelvin
        
        func interpolate(_ value: CGFloat, a: CGFloat, b:CGFloat, c:CGFloat) -> CGFloat {
            a + b * value + c * log(value)
        }
        var red, green, blue: CGFloat
        if k < 6600 {
            red = 255
            green = interpolate(k/100-2, a: -155.25485562709179, b: -0.44596950469579133, c: 104.49216199393888)
            if k < 2000 {
                blue = 0
            } else {
                blue = interpolate(k/100-10, a: -254.76935184120902, b: 0.8274096064007395, c: 115.67994401066147)
            }
        } else {
            red = interpolate(k/100-55, a: 351.97690566805693, b: 0.114206453784165, c: -40.25366309332127)
            green = interpolate(k/100-50, a: 325.4494125711974, b: 0.07943456536662342, c: -28.0852963507957)
            blue = 255
        }
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    static func componentsForColorTemperature(_ temperature: CGFloat) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let range = UInt8.range.cgFloatRange
        let percentKelvin = temperature / 100
        let red, green, blue: CGFloat
        
        red = range << (percentKelvin <= 66 ? 255 : (329.698727446 * pow(percentKelvin - 60, -0.1332047592)))
        green = range << (percentKelvin <= 66 ? (99.4708025861 * log(percentKelvin) - 161.1195681661) : 288.1221695283 * pow(percentKelvin - 60, -0.0755148492))
        blue = range << (percentKelvin >= 66 ? 255 : (percentKelvin <= 19 ? 0 : 138.5177312231 * log(percentKelvin - 10) - 305.0447927307))
        
        return (red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
    }
    
    // MARK: - __________ Instance __________
    
    
    /// 调整白平衡
    /// - Parameters:
    ///   - temperature: 色温
    ///   - gm: 红绿补偿 | 范围 -100...100 -> 偏红...偏绿
    /// - Returns: 调整后生成新颜色
    func whiteBalance(_ temperature: CGFloat? = nil, gm: CGFloat? = nil) -> UIColor {
        guard let rgba else { return self }
        /// 创建色温滤镜
        guard let filter = CIFilter(name: "CITemperatureAndTint") else {
            dprint("过滤器创建失败")
            return self
        }
        let ciColor = CIColor(red: rgba.red, green: rgba.green, blue: rgba.blue)
        let inputCIImage = CIImage(color: ciColor)
        /// 色温
        let x = temperature.or(6500.0)
        /// 红绿补偿 | KNOWLED项目里滑块逻辑和这里是相反的,所以这里要取相反数
        let y = gm.map(fallback: 0) { -1.0 * $0 }
        /// 设置相关参数
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: x, y: y), forKey: "inputNeutral")
        filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral")
        guard let outputImage = filter.outputImage else {
            dprint("输出失败")
            return self
        }
        /// 准备相关参数
        /// 指定一小块范围用以创建图像 | 直接用outputImage.extent属性就太大了
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let format = CIFormat.RGBA8
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        var options: [CIContextOption: Any] = [:]
        options[.outputColorSpace] = colorSpace
        let context = CIContext(options: options)
        
        guard let cgImage = context.createCGImage(outputImage, from: rect, format: format, colorSpace: colorSpace) else {
            dprint("cgImage 创建失败")
            return self
        }
        let uiImage = UIImage(cgImage: cgImage)
        return UIColor(patternImage: uiImage)
    }
    
    /// UIColor -> UIImage
    /// - Parameters:
    ///   - size: 图片尺寸(Pt)
    ///   - cornerRadius: 圆角
    /// - Returns: UIImage实例
    func uiImage(size: CGSize = 1, cornerRadius: CGFloat? = nil) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = renderer.image { context in
            self.setFill()
            context.fill(context.format.bounds)
        }
        /// 添加圆角
        if let cornerRadius {
            /// 图片尺寸
            let renderSize = uiImage.size
            /// 圆角矩形Rect
            let roundedRect = CGRect(origin: .zero, size: renderSize)
            /// 重新生成图片
            return UIGraphicsImageRenderer(size: renderSize).image { ctx in
                UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius).addClip()
                uiImage.draw(in: roundedRect)
            }
        } else {
            return uiImage
        }
    }
    
    func viewWithSize(_ size: CGFloat, constrained: Bool = true) -> UIView {
        view(UIView.self, size: size, constrained: constrained)
    }
    
    func view<T>(_ type: T.Type, size: CGFloat, constrained: Bool = true) -> T where T: UIView {
        view(type, width: size, height: size, constrained: constrained)
    }
    
    func view<T>(_ type: T.Type, width: CGFloat, height: CGFloat, constrained: Bool = true) -> T where T: UIView {
        let size = CGSize(width: width, height: height)
        let rect = CGRect(origin: .zero, size: size)
        let view = T(frame: rect)
        view.backgroundColor = self
        if constrained {
            view.fix(width: width, height: height)
        }
        return view
    }
}

extension Int {
	
    @available(iOS 13.0, *)
    var cgColor: CGColor {
		guard let rgba else { return UIColor.clear.cgColor }
		return CGColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
	}
	
	var uiColor: UIColor {
        rgba.map(fallback: .clear, UIColor.init)
	}
    
    /// 整型 -> ARGB
	var rgba: RGBA? {
        let maxRGB = 0xFF_FF_FF
        let maxARGB = 0xFF_FF_FF_FF
        switch self {
        case 0...maxRGB:
            /// 不带透明度的情况
            let red     = CGFloat((self & 0xFF_00_00) >> 16) / 0xFF
            let green   = CGFloat((self & 0x00_FF_00) >>  8) / 0xFF
            let blue    = CGFloat( self & 0x00_00_FF       ) / 0xFF
            return RGBA(red: red, green: green, blue: blue)
        case maxRGB.number...maxARGB:
            /// 带透明度的情况
            let alpha   = CGFloat((self & 0xFF_00_00_00) >> 24) / 0xFF
            let red     = CGFloat((self & 0x00_FF_00_00) >> 16) / 0xFF
            let green   = CGFloat((self & 0x00_00_FF_00) >>  8) / 0xFF
            let blue    = CGFloat( self & 0x00_00_00_FF       ) / 0xFF
            return RGBA(red: red, green: green, blue: blue, alpha: alpha)
        default:
            /// 其他情况
            return nil
        }
	}
}

extension String {
    
    /// 从十六进制字符串转换颜色
    var uiColor: UIColor {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        if #available(iOS 13.0, *) {
            guard let int = scanner.scanInt(representation: .hexadecimal) else { return .clear }
            return int.uiColor
        } else {
            var uint: UInt64 = 0
            scanner.scanHexInt64(&uint)
            return Int(uint).uiColor
        }
    }
}
