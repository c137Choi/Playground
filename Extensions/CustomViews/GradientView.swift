//
//  GradientView.swift
//
//  Created by Choi on 2022/8/26.
//

import UIKit

// MARK: - 渐变View
class GradientView: UIView {
    
    typealias GradientLayer = CAGradientLayer
    
    override class var layerClass: AnyClass { GradientLayer.self }
    
    var gradientColors: GradientColors = [] {
        willSet {
            gradientLayer.setColors(newValue)
        }
    }
    
    init(direction: CGVector = .right, gradientColors: GradientColors = []) {
        super.init(frame: .zero)
        /// 设置渐变色
        self.gradientColors = gradientColors
        /// 上面属性的observer方法不会执行,这里手动执行一次
        self.gradientLayer.setColors(gradientColors)
        /// 设置方向
        setDirection(direction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refill(@ArrayBuilder<ColorStop> _ gradientBuilder: GradientColorsBuilder) {
        gradientColors = gradientBuilder()
    }

    func setDirection(_ vector: CGVector) {
        gradientLayer.setDirection(vector)
    }
}

extension GradientView {
    
    convenience init(direction: CGVector = .right, @ArrayBuilder<ColorStop> _ gradientBuilder: GradientColorsBuilder) {
        let gradientColors = gradientBuilder()
        self.init(direction: direction, gradientColors: gradientColors)
    }
    
    /// 渐变图层
    var gradientLayer: GradientLayer {
        layer as! GradientLayer
    }
}
