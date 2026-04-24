//
//  CAGradientLayerPlus.swift
//
//  Created by Choi on 2022/10/8.
//

import UIKit

// MARK: - 渐变色封装
struct ColorStop {
    let color: UIColor
    let stop: Double
    init(color: UIColor, stop: Double = -1) {
        self.color = color
        self.stop = stop
    }
    
    /// 从HUE创建对象
    /// - Parameters:
    ///   - hue: 色相 (范围: 0 - 1)
    static func fromHue(_ hue: Double) -> ColorStop {
        let color = UIColor(hue: hue)
        return self.init(color: color)
    }
}

extension UIColor {
    var colorStop: ColorStop {
        ColorStop(color: self)
    }
}

typealias GradientColors = [ColorStop]
typealias GradientColorsBuilder = () -> GradientColors
extension GradientColors {
    /// 纯色渐变
    static func solid(color: UIColor) -> GradientColors {
        GradientColors {
            ColorStop(color: color)
        }
    }
}

// MARK: - 渐变图层封装
extension CAGradientLayer {
    
    convenience init(direction: CGVector = .right, @ArrayBuilder<ColorStop> _ gradientBuilder: GradientColorsBuilder = { [] }) {
        self.init()
        /// 设置渐变色
        let gradientColors = gradientBuilder()
        setColors(gradientColors)
        /// 设置方向
        setDirection(direction)
    }
    
    func refill(@ArrayBuilder<ColorStop> _ gradientBuilder: GradientColorsBuilder) {
        let colors = gradientBuilder()
        setColors(colors)
    }
    
    var direction: CGVector {
        get {
            CGVector(start: startPoint, end: endPoint)
        }
        set {
            setDirection(newValue)
        }
    }
    
    var gradientColors: GradientColors? {
        get { nil }
        set { setColors(newValue) }
    }
    
    /// 设置渐变方向
    /// - Parameter vector: 方向
    func setDirection(_ vector: CGVector) {
        let points = vector.positivePoints
        startPoint = points.start
        endPoint = points.end
    }
    
    /// 设置渐变色
    /// - Parameter gradientColors: 渐变色数组
    func setColors(_ gradientColors: GradientColors?) {
        guard let gradientColors else { return }
        if gradientColors.count == 1 {
            colors = [gradientColors.first, gradientColors.last].unwrapped.map(\.color.cgColor)
        } else {
            colors = gradientColors.map(\.color.cgColor)
        }
        
        /// 设置渐变图层颜色停顿位置
        switch gradientColors.count {
        case 1:
            locations = [0.0, 1.0].map(\.nsNumber)
        case 2...:
            let stopsAreLegal = gradientColors.allSatisfy { colorStop in
                0.0...1.0 ~= colorStop.stop
            }
            guard stopsAreLegal else { return locations = nil }
            locations = gradientColors.map(\.stop).map(\.nsNumber)
        default:
            locations = nil
        }
    }
}
