//
//  ColorModels.swift
//  KnowLED
//
//  Created by Choi on 2025/12/11.
//

import UIKit

// MARK: - RGBA
struct RGBA {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double = 1.0
}

extension RGBA {
    static let white = RGBA(red: 1, green: 1, blue: 1)
    static let black = RGBA(red: 0, green: 0, blue: 0)
    
    /// 初始化方法
    /// - Parameter rawInt: ARGB格式的整形数值
    init?(_ rawInt: Int) {
        let maxRGB = 0xFF_FF_FF
        let maxARGB = 0xFF_FF_FF_FF
        switch rawInt {
        case let rawInt where rawInt >= 0 && rawInt <= maxRGB:
            self.red   = Double((rawInt & 0xFF_00_00) >> 16) / 0xFF
            self.green = Double((rawInt & 0x00_FF_00) >>  8) / 0xFF
            self.blue  = Double( rawInt & 0x00_00_FF       ) / 0xFF
            self.alpha = 1.0
        case let rawInt where rawInt > maxRGB && rawInt <= maxARGB:
            self.alpha = Double((rawInt & 0xFF_00_00_00) >> 24) / 0xFF
            self.red   = Double((rawInt & 0x00_FF_00_00) >> 16) / 0xFF
            self.green = Double((rawInt & 0x00_00_FF_00) >>  8) / 0xFF
            self.blue  = Double( rawInt & 0x00_00_00_FF       ) / 0xFF
        default:
            return nil
        }
    }
    
    init?(_ uiColor: UIColor) {
        var red = CGFloat.zero, green = CGFloat.zero, blue = CGFloat.zero, alpha = CGFloat.zero
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
    }
    
    var clamped: RGBA {
        RGBA(red: Double.percentRange << red, green: Double.percentRange << green, blue: Double.percentRange << blue, alpha: Double.percentRange << alpha)
    }
    
    var rgbArray: [Double] {
        [red, green, blue]
    }
}

extension RGBA: Comparable {
    
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

// MARK: - GammaCorrection
protocol GammaCorrection {
    func transform(_ value: Double) -> Double
    func invTransform(_ value: Double) -> Double
}

struct NoGammaCorrection: GammaCorrection {
    func transform(_ value: Double) -> Double { value }
    func invTransform(_ value: Double) -> Double { value }
}

struct StandardGammaCorrection: GammaCorrection {
    let gamma: Double
    let transition: Double
    let slope: Double
    let offset: Double
    let gammaInv: Double
    let slopeInv: Double
    private(set) var transitionInv = 0.0
    
    init(gamma: Double, transition: Double, slope: Double, offset: Double) {
        self.gamma = gamma
        self.transition = transition
        self.slope = slope
        self.offset = offset
        self.gammaInv = 1 / gamma
        self.slopeInv = 1 / slope
        self.transitionInv = transform(transition)
    }
    
    func transform(_ value: Double) -> Double {
        value <= transition ? slope * value : (1 + offset) * pow(value, gamma) - offset
    }
    
    func invTransform(_ value: Double) -> Double {
        value <= transitionInv ? value * slopeInv : pow((value + offset) / (1 + offset), gammaInv)
    }
}

struct Matrix3 {
    
    static let identity = Matrix3(1, 0, 0, 0, 1, 0, 0, 0, 1)
    
    var elements: [Double]
    
    init(_ elements: Double...) {
        if elements.count != 9 {
            fatalError("元素数量不匹配")
        }
        self.elements = elements
    }
    
    func timesArray(_ array: [Double]) -> [Double] {
        var result = [Double](repeating: 0, count: 3)
        for i in 0..<3 {
            for n in 0..<3 {
                result[i] += elements[i * 3 + n] * array[n]
            }
        }
        return result
    }
    
    fileprivate var inversed: Matrix3 {
        // Set inverse to the identity matrix
        var current = self
        var inverse = Matrix3.identity
        
        // Gaussian elimination (part 1)
        for i in 0..<3 {
            // Get the diagonal term
            var d = current.elements[i * 3 + i]
            
            // If it is 0, there must be at least one row with a non-zero element (otherwise, the matrix is not invertible)
            if (d == 0) {
                var r = i + 1
                while r < 3 && abs(current.elements[r * 3 + i]) < 1e-10 {
                    r += 1
                }
                if r == 3 {
                    return .identity
                }
                for c in 0..<3 {
                    current.elements[i * 3 + c] += current.elements[r * 3 + c]
                    inverse.elements[i * 3 + c] += inverse.elements[r * 3 + c]
                }
                d = current.elements[i * 3 + i]
            }
            
            // Divide the row by the diagonal term
            let inv = 1 / d
            for c in 0..<3 {
                current.elements[i * 3 + c] *= inv
                inverse.elements[i * 3 + c] *= inv
            }
            
            // Divide all subsequent rows with a non-zero coefficient, and subtract the row
            for r in (i+1)..<3 {
                let p = current.elements[r * 3 + i]
                if p != 0 {
                    for c in 0..<3 {
                        current.elements[r * 3 + c] -= current.elements[i * 3 + c] * p
                        inverse.elements[r * 3 + c] -= inverse.elements[i * 3 + c] * p
                    }
                }
            }
        }
        
        // Gaussian elimination (part 2)
        var i = 2
        while i >= 0 {
            defer {
                i -= 1
            }
            for r in 0..<i {
                let d = current.elements[r * 3 + i]
                for c in 0..<3 {
                    current.elements[r * 3 + c] -= current.elements[i * 3 + c] * d
                    inverse.elements[r * 3 + c] -= inverse.elements[i * 3 + c] * d
                }
            }
        }
        return inverse
    }
}

enum ColorSpace {
    case sRGB
    case adobeRGB
    case wide
    
    static let matrix_sRGB = Matrix3(0.412453, 0.35758, 0.180423, 0.212671, 0.71516, 0.072169, 0.019334, 0.119193, 0.950227)
    static let matrix_adobeRGB = Matrix3(0.5767, 0.1856, 0.1882, 0.2974, 0.6273, 0.0753, 0.0270, 0.0707, 0.9911)
    static let matrix_wide = Matrix3(0.7164, 0.1010, 0.1468, 0.2587, 0.7247, 0.0166, 0.0000, 0.0512, 0.7740)
    
    static let matrixInv_sRGB = matrix_sRGB.inversed
    static let matrixInv_adobeRGB = matrix_adobeRGB.inversed
    static let matrixInv_wide = matrix_wide.inversed
    
    static let gammaCorrection_sRGB = StandardGammaCorrection(gamma: 0.42, transition: 0.0031308, slope: 12.92, offset: 0.055)
    static let gammaCorrection_adobeRGB = NoGammaCorrection()
    static let gammaCorrection_wide = gammaCorrection_adobeRGB
    
    private var matrix: Matrix3 {
        switch self {
        case .sRGB:
            ColorSpace.matrix_sRGB
        case .adobeRGB:
            ColorSpace.matrix_adobeRGB
        case .wide:
            ColorSpace.matrix_wide
        }
    }
    
    private var matrixInv: Matrix3 {
        switch self {
        case .sRGB:
            ColorSpace.matrixInv_sRGB
        case .adobeRGB:
            ColorSpace.matrixInv_adobeRGB
        case .wide:
            ColorSpace.matrixInv_wide
        }
    }
    
    private var gammaCorrection: GammaCorrection {
        switch self {
        case .sRGB:
            ColorSpace.gammaCorrection_sRGB
        case .adobeRGB:
            ColorSpace.gammaCorrection_adobeRGB
        case .wide:
            ColorSpace.gammaCorrection_wide
        }
    }
    
    func xyFromColor(_ color: RGBA) -> XY? {
        let xyY = xyYFromColor(color)
        return XY(uncheckedX: xyY.x, uncheckedY: xyY.y)
    }
    
    func color(x: Double, y: Double) -> RGBA {
        let maxY = findMaximumY(x, y: y)
        return colorFromXYY(x, y, maxY).clamped
    }
    
    private func xyYFromColor(_ color: RGBA) -> (x: Double, y: Double, Y: Double) {
        if color.red < 1e-12 && color.green < 1e-12 && color.blue < 1e-12 {
            let xyz = xyzFromColor(.white)
            let sum = xyz.x + xyz.y + xyz.z
            return (xyz.x / sum, xyz.y / sum, 0)
        }
        let xyz = xyzFromColor(color)
        let sum = xyz.x + xyz.y + xyz.z
        return (xyz.x / sum, xyz.y / sum, xyz.y)
    }
    
    private func xyzFromColor(_ color: RGBA) -> (x: Double, y: Double, z: Double) {
        @ArrayBuilder<Double> var rgb: [Double] {
            gammaCorrection.invTransform(color.red)
            gammaCorrection.invTransform(color.green)
            gammaCorrection.invTransform(color.blue)
        }
        let elements = matrix.timesArray(rgb)
        return (elements[0], elements[1], elements[2])
    }
    
    private func findMaximumY(_ x: Double, y: Double, iterations: Int = 10) -> Double {
        var bri = 1.0
        for _ in 0..<iterations {
            let color = colorFromXYY(x, y, bri)
            bri /= max(color.red, color.green, color.blue)
        }
        return bri
    }
    
    private func colorFromXYY(_ x: Double, _ y: Double, _ Y: Double) -> RGBA {
        let z = 1.0 - x - y
        let Yy = Y / y
        return colorFromXYZ(Yy * x, Y, Yy * z)
    }
    
    private func colorFromXYZ(_ x: Double, _ y: Double, _ z: Double) -> RGBA {
        let elements = matrixInv.timesArray([x, y, z])
        let red = gammaCorrection.transform(elements[0])
        let green = gammaCorrection.transform(elements[1])
        let blue = gammaCorrection.transform(elements[2])
        return RGBA(red: red, green: green, blue: blue, alpha: 1)
    }
}

/// 色域
enum ColorGamut: CaseIterable {
    case bt2020
    
    var M: [[Double]] {
        Array<[Double]> {
            switch self {
            case .bt2020:
                [0.6370, 0.2627, 0.0000]
                [0.1446, 0.6780, 0.0281]
                [0.1689, 0.0593, 1.0610]
            }
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
