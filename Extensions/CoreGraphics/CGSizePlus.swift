//
//  CoreGraphicPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2020/9/16.
//  Copyright © 2020 Choi. All rights reserved.
//

import UIKit

extension CGSize {
    
    var pointSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: width / scale, height: height / scale)
    }
    
    var pixelSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: width * scale, height: height * scale)
    }
    
    /// 面积
    var area: CGFloat {
        width * height
    }
    
    /// 竖屏尺寸(宽小于高)
    var portrait: CGSize {
        guard width != height else { return self }
        let newWidth = min(width, height)
        let newHeight = max(width, height)
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /// 横屏尺寸(宽大于高)
    var landscape: CGSize {
        guard width != height else { return self }
        let newWidth = max(width, height)
        let newHeight = min(width, height)
        return CGSize(width: newWidth, height: newHeight)
    }
    
    var isPortrait: Bool {
        guard width != height else { return true }
        return width < height
    }
    
    var isLandscape: Bool {
        guard width != height else { return true }
        return width > height
    }
    
	init(_ edges: CGFloat...) {
		guard let width = edges.first else { self.init(width: 0, height: 0); return }
		guard let height = edges.last else { self.init(width: 0, height: 0); return }
		self.init(width: width, height: height)
	}
    
    
    /// 限制尺寸 | 不能超过指定尺寸范围的宽高
    /// - Parameters:
    ///   - minSize: 最小尺寸
    ///   - maxSize: 最大尺寸
    func limit(minSize: CGSize? = nil, maxSize: CGSize? = nil) -> CGSize {
        var tempSize = self
        minSize.unwrap { minSize in
            tempSize.width = max(width, minSize.width)
            tempSize.height = max(height, minSize.height)
        }
        maxSize.unwrap { maxSize in
            tempSize.width = min(width, maxSize.width)
            tempSize.height = min(height, maxSize.height)
        }
        return tempSize
    }
    
    func heightOffset(_ heightOffset: CGFloat) -> CGSize {
        CGSize(width: width, height: height + heightOffset)
    }
    
    func widthOffset(_ widthOffset: CGFloat) -> CGSize {
        CGSize(width: width + widthOffset, height: height)
    }
    
	/// 给CGSize加另外的宽高
	/// - Parameters:
	///   - lhs: CGSize
	///   - rhs: 遵循了ExtendableBySize协议的对象
	/// - Returns: A new CGSize
	static func + (lhs: CGSize, rhs: SizeExtendable) -> CGSize {
		var size = lhs
		size.width += rhs.horizontal
		size.height += rhs.vertical
		return size
	}
    
    /// 宽高乘以指定的比率
    static func * (lhs: CGSize, rhs: Double) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    /// 宽高分别乘以rhs的宽高
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    /// 对角线长度
    var diagonal: CGFloat {
        /// 两边的平方和
        let quadraticSum = pow(width, 2.0) + pow(height, 2.0)
        /// 开平方
        return sqrt(quadraticSum)
    }
    
    /// 旋转 | 交换宽高
    var rotated: CGSize {
        CGSize(width: height, height: width)
    }
    
    /// height / width
    var ratio: CGFloat {
        height / width
    }
    
    func multiplied(by: CGFloat) -> CGSize {
        var size = self
        size.width *= by
        size.height *= by
        return size
    }
	
	func chopEqually(times: Int, direction: NSLayoutConstraint.Axis) -> CGSize {
		var size = self
		switch direction {
		case .vertical: size.width /= times.cgFloat
		case .horizontal: size.height /= times.cgFloat
		@unknown default: break
		}
		return size
	}
    
    /// 给定中心点返回CGRect
    func rect(center: CGPoint) -> CGRect {
        let origin = CGPoint(x: center.x - width.half, y: center.y - height.half)
        return CGRect(origin: origin, size: self)
    }
}

extension CGSize: @retroactive ExpressibleByFloatLiteral {
	public init(floatLiteral value: Double) {
		self.init(width: value, height: value)
	}
}

extension CGSize: @retroactive ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self.init(width: value, height: value)
	}
}

extension CGSize: @retroactive Comparable {
	public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
		lhs.width * lhs.height < rhs.width * rhs.height
	}
}
