//
//  UIColorPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/11.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

typealias Kelvin = CGFloat

/// 色域
enum ColorGamut: CaseIterable, CustomStringConvertible {
    case adobeRGB1998
    case appleRGB
    case bestRGB
    case cieRGB
    case sRGB
    case wideGamutRGB
    
    case rec709
    case dciP3
    case bt2020
    
    var gamma: Double {
        switch self {
        case .adobeRGB1998:
            return 2.2
        case .appleRGB:
            return 1.8
        case .bestRGB:
            return 2.2
        case .cieRGB:
            return 2.2
        case .sRGB:
            return 2.2
        case .wideGamutRGB:
            return 2.2
        case .rec709:
            return 1.0 /// 未知,使用1.0填充
        case .dciP3:
            return 1.0 /// 未知,使用1.0填充
        case .bt2020:
            return 1.0 /// 未知,使用1.0填充
        }
    }
    
    var M: [[Double]] {
        Array<[Double]> {
            switch self {
            case .adobeRGB1998:
                [0.5767309, 0.1855540, 0.1881852]
                [0.2973769, 0.6273491, 0.0752741]
                [0.0270343, 0.0706872, 0.9911085]
            case .appleRGB:
                [0.4497288, 0.3162486, 0.1844926]
                [0.2446525, 0.6720283, 0.0833192]
                [0.0251848, 0.1411824, 0.9224628]
            case .bestRGB:
                [0.6326696, 0.2045558, 0.1269946]
                [0.2284569, 0.7373523, 0.0341908]
                [0.0000000, 0.0095142, 0.8156958]
            case .cieRGB:
                [0.4887180, 0.3106803, 0.2006017]
                [0.1762044, 0.8129847, 0.0108109]
                [0.0000000, 0.0102048, 0.9897952]
            case .sRGB:
                [0.4124564, 0.3575761, 0.1804375]
                [0.2126729, 0.7151522, 0.0721750]
                [0.0193339, 0.1191920, 0.9503041]
            case .wideGamutRGB:
                [0.7161046, 0.1009296, 0.1471858]
                [0.2581874, 0.7249378, 0.0168748]
                [0.0000000, 0.0517813, 0.7734287]
            case .rec709:
                [0.4124, 0.2126, 0.0190]
                [0.3575, 0.7151, 0.1191]
                [0.1804, 0.0721, 0.9503]
            case .dciP3:
                [0.4864, 0.2289 , 0.000]
                [0.2656, 0.6917 , 0.045]
                [0.1972, 0.07929, 1.043]
            case .bt2020:
                [0.6370, 0.2627, 0.0000]
                [0.1446, 0.6780, 0.0281]
                [0.1689, 0.0593, 1.0610]
            }
        }
    }
    
    var MReverse: [[Double]] {
        Array<[Double]> {
            switch self {
            case .adobeRGB1998:
                [ 2.0413690, -0.5649464, -0.3446944]
                [-0.9692660,  1.8760108,  0.0415560]
                [ 0.0134474, -0.1183897,  1.0154096]
            case .appleRGB:
                [ 2.9515373, -1.2894116, -0.4738445]
                [-1.0851093,  1.9908566,  0.0372026]
                [ 0.0854934, -0.2694964,  1.0912975]
            case .bestRGB:
                [ 1.7552599, -0.4836786, -0.2530000]
                [-0.5441336,  1.5068789,  0.0215528]
                [ 0.0063467, -0.0175761,  1.2256959]
            case .cieRGB:
                [ 2.3706743, -0.9000405, -0.4706338]
                [-0.5138850,  1.4253036,  0.0885814]
                [ 0.0052982, -0.0146949,  1.0093968]
            case .sRGB:
                [ 3.2404542, -1.5371385, -0.4985314]
                [-0.9692660,  1.8760108,  0.0415560]
                [ 0.0556434, -0.2040259,  1.0572252]
            case .wideGamutRGB:
                [ 1.4628067, -0.1840623, -0.2743606]
                [-0.5217933,  1.4472381,  0.0677227]
                [ 0.0349342, -0.0968930,  1.2884099]
            case .rec709:
                [ 3.2400, -0.9690,  0.0550]
                [-1.5370,  1.8760, -0.2040]
                [-0.4985,  0.0415,  1.0572]
            case .dciP3:
                [ 2.494, -0.830,  0.036]
                [-0.932,  1.763, -0.076]
                [-0.401,  0.023,  0.958]
            case .bt2020:
                [ 1.7167, -0.6667,  0.0176]
                [-0.3557,  1.6165, -0.0428]
                [-0.2534,  0.0158,  0.9421]
            }
        }
    }
    
    var description: String {
        switch self {
        case .adobeRGB1998:
            return "adobeRGB1998"
        case .appleRGB:
            return "appleRGB"
        case .bestRGB:
            return "bestRGB"
        case .cieRGB:
            return "cieRGB"
        case .sRGB:
            return "sRGB"
        case .wideGamutRGB:
            return "wideGamutRGB"
        case .rec709:
            return "rec709"
        case .dciP3:
            return "dciP3"
        case .bt2020:
            return "bt2020"
        }
    }
}

/// 颜色混合时传入的元素
struct ColorBlendComponent {
    let color: UIColor
    let weight: CGFloat
    
    init?(color: UIColor?, weight: CGFloat?) {
        guard let color, let weight else { return nil }
        self.color = color
        self.weight = weight
    }
    
    init?(color: UIColor?, weight: Double?) {
        guard let color, let weight else { return nil }
        self.color = color
        self.weight = weight
    }
}

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
    var temperature: Kelvin {
        guard let aRGB else { return 0 }
        let r = aRGB.red
        let g = aRGB.green
        let b = aRGB.blue
        
        /// RGB -> XYZ color space
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505
        
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
        hsba.or(0, map: \.hue)
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
    var kelvin: Kelvin? {
        guard let aRGB else { return nil }
        let red = aRGB.red
        let green = aRGB.green
        let blue = aRGB.blue
        let temp = (0.23881 * red + 0.25499 * green - 0.58291 * blue) / (0.11109 * red - 0.85406 * green + 0.52289 * blue)
        let colorTemperature = 449 * pow(temp, 3) + 3525 * pow(temp, 2) + 6823.3 * temp + 5520.33
        return colorTemperature
    }
    
    var aRGB: ARGB? {
        var a: CGFloat = 0.0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return ARGB(alpha: a, red: r, green: g, blue: b)
    }
    
    /// 转换成xy色域坐标
    /// - Parameter colorGamut: 色域
    /// - Returns: xy坐标
    func xy(colorGamut: ColorGamut) -> XY {
        /// 取出颜色元素
        guard let aRGB else { return .zero }
        /// 求出XYZ = 向量 * 矩阵
        let XYZ = aRGB.rgbArray * colorGamut.M
        /// XYZ求和
        let XYZSum = XYZ.reduce(0.0, +)
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
    /// - Parameter kelvin: 色温 | 单位: 开尔文
    /// - Returns: UIColor对象
    static func fromTemperature(_ kelvin: Kelvin) -> UIColor {
        UIColor(temperature: kelvin)
    }
    
    /// 从色温创建颜色
    /// - Parameter temperature: 色温
    /// https://github.com/davidf2281/ColorTempToRGB
    /// https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
    convenience init(temperature: Kelvin) {
        let components = UIColor.componentsForColorTemperature(temperature)
        self.init(red: components.red, green: components.green, blue: components.blue, alpha: 1.0)
    }
    
//    convenience init(x: Double, y: Double, colorGamut: ColorGamut) {
//        let XYZ = [x / y, 1.0, (1.0 - x - y) / y]
//        let MReverse = colorGamut.MReverse
//        let range = 0...1.0
//        let rgb = (XYZ * MReverse).map {
//            let constrainedValue = range << $0
//            return pow(constrainedValue, 1.0 / colorGamut.gamma)
//        }
//        guard rgb.count >= 3 else {
//            self.init(white: 0, alpha: 0)
//            return
//        }
//        let r = rgb[0]
//        let g = rgb[1]
//        let b = rgb[2]
//        self.init(red: r, green: g, blue: b, alpha: 1.0)
//    }
    
    convenience init(argb: ARGB) {
        self.init(red: argb.red, green: argb.green, blue: argb.blue, alpha: argb.alpha)
    }
    
    convenience init(xy: XY) {
        self.init(x: xy.x, y: xy.y)
    }
    
    /// XY坐标创建颜色
    convenience init(x: Double, y: Double) {
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
            if let aRGB = component.color.aRGB {
                red += aRGB.red * component.weight
                green += aRGB.green * component.weight
                blue += aRGB.blue * component.weight
                alpha += aRGB.alpha * component.weight
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
    
    static func componentsForColorTemperature(_ temperature: Kelvin) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
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
    func whiteBalance(_ temperature: Kelvin? = nil, gm: CGFloat? = nil) -> UIColor {
        guard let aRGB else { return self }
        /// 创建色温滤镜
        guard let filter = CIFilter(name: "CITemperatureAndTint") else {
            dprint("过滤器创建失败")
            return self
        }
        let ciColor = CIColor(red: aRGB.red, green: aRGB.green, blue: aRGB.blue)
        let inputCIImage = CIImage(color: ciColor)
        /// 色温
        let x = temperature.or(6500.0)
        /// 红绿补偿 | KNOWLED项目里滑块逻辑和这里是相反的,所以这里要取相反数
        let y = gm.or(0) { -1.0 * $0 }
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
		guard let aRGB else { return UIColor.clear.cgColor }
		return CGColor(red: aRGB.red, green: aRGB.green, blue: aRGB.blue, alpha: aRGB.alpha)
	}
	
	var uiColor: UIColor {
		guard let aRGB else { return .clear }
		return UIColor(red: aRGB.red, green: aRGB.green, blue: aRGB.blue, alpha: aRGB.alpha)
	}
    
    /// 整型 -> ARGB
	var aRGB: ARGB? {
        let maxRGB = 0xFF_FF_FF
        let maxARGB = 0xFF_FF_FF_FF
        switch self {
        case 0...maxRGB:
            /// 不带透明度的情况
            let red     = CGFloat((self & 0xFF_00_00) >> 16) / 0xFF
            let green   = CGFloat((self & 0x00_FF_00) >>  8) / 0xFF
            let blue    = CGFloat( self & 0x00_00_FF       ) / 0xFF
            return ARGB(red: red, green: green, blue: blue)
        case maxRGB.number...maxARGB:
            /// 带透明度的情况
            let alpha   = CGFloat((self & 0xFF_00_00_00) >> 24) / 0xFF
            let red     = CGFloat((self & 0x00_FF_00_00) >> 16) / 0xFF
            let green   = CGFloat((self & 0x00_00_FF_00) >>  8) / 0xFF
            let blue    = CGFloat( self & 0x00_00_00_FF       ) / 0xFF
            return ARGB(alpha: alpha, red: red, green: green, blue: blue)
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
