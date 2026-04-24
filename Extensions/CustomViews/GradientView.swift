//
//  GradientView.swift
//
//  Created by Choi on 2022/8/26.
//

import UIKit

// MARK: - 渐变View
class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    convenience init(direction: CGVector, @ArrayBuilder<ColorStop> _ gradientBuilder: GradientColorsBuilder) {
        self.init(direction: direction, gradientColors: gradientBuilder())
    }
    
    convenience init(direction: CGVector, gradientColors: GradientColors = []) {
        self.init(frame: .zero)
        /// 设置渐变色
        self.gradientLayer.setColors(gradientColors)
        /// 设置方向
        self.gradientLayer.setDirection(direction)
    }
    
    var gradientColors: GradientColors? {
        get { gradientLayer.gradientColors }
        set { gradientLayer.gradientColors = newValue }
    }
    
    var direction: CGVector {
        get { gradientLayer.direction }
        set { gradientLayer.direction = newValue }
    }
    
    /// 渐变图层
    var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }
}
