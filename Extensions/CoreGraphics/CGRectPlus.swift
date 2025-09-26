//
//  CGRectPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/18.
//  Copyright © 2021 Choi. All rights reserved.
//

import CoreGraphics
import UIKit

extension CGRect {
    
    /// 左上角点
    var topLeft: CGPoint {
        CGPoint(x: minX, y: minY)
    }
    
    /// 右上角点
    var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }
    
    /// 左下角点
    var bottomLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }
    
    /// 右下角点
    var bottomRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
    
    /// 将传入的点限制在自身区域中
    /// - Parameter point: 传入的点
    /// - Returns: 限制后的点
    func constrainedPoint(_ point: CGPoint) -> CGPoint {
        let xRange = minX...maxX
        let yRange = minY...maxY
        return CGPoint(x: xRange << point.x, y: yRange << point.y)
    }
    
    /// 从当前Frame生成随机Frame
    /// - Parameter fixSize: 固定随机Rect尺寸
    /// - Returns: 随机尺寸
    func randomPosition(fixSize: CGSize) -> CGRect {
        let x = CGFloat.random(in: minX...maxX - fixSize.width)
        let y = CGFloat.random(in: minY...maxY - fixSize.height)
        let origin = CGPoint(x: x, y: y)
        return CGRect(origin: origin, size: fixSize)
    }
    
    /// 以像素为单位的Rect
    var pixelRect: CGRect {
        let scale = UIScreen.main.scale
        return CGRect(x: origin.x * scale, y: origin.y * scale, width: size.width * scale, height: size.height * scale)
    }
    
    /// 按照X轴线向上翻转之后的Rect | 用于SPriteKit中的坐标运算
    var flipped: CGRect {
        CGRect(x: origin.x, y: -origin.y, width: width, height: height)
    }
    
    var area: CGFloat {
        size.area
    }
    
    /// 对角线长度
    var diagonal: CGFloat {
        size.diagonal
    }
    
	/// 中心点
	var center: CGPoint {
        get {
            CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(x: newValue.x - width.half, y: newValue.y - height.half)
        }
	}
    
    /// SpriteKit节点Frame的中心点
    var skNodeCenter: CGPoint {
        CGPoint(x: midX, y: origin.y - size.height / 2.0)
    }
	
	/// 对Rect进行缩放
	/// - Parameter ratio: 缩放比率
	mutating func zoom(_ ratio: CGFloat) {
		origin.x *= ratio
		origin.y *= ratio
		size.width *= ratio
		size.height *= ratio
	}
	
	/// 对Rect进行缩放
	/// - Parameter ratio: 比率
	/// - Returns: 缩放后的Rect
	func zoomed(_ ratio: CGFloat) -> CGRect {
		var newRect = self
		newRect.zoom(ratio)
		return newRect
	}
	func insetBySize(_ size: CGSize) -> CGRect {
		insetBy(dx: size.width, dy: size.height)
	}
	func offsetBySize(_ size: CGSize) -> CGRect {
		offsetBy(dx: size.width, dy: size.height)
	}
}

extension CGRect {
    
    
    /// 将右侧的Rect限制在左侧的Rect内
    static func <<(lhs: CGRect, rhs: CGRect) -> CGRect {
        /// 确保两个Rect都非空
        if lhs.isEmpty || rhs.isEmpty { return .zero }
        /// 左侧的Rect看做容器Rect
        let containerMinX = lhs.minX
        let containerMinY = lhs.minY
        let containerWidth = lhs.width
        let containerHeight = lhs.height
        /// 右侧的Rect看做被约束的Rect
        let x = rhs.minX
        let y = rhs.minY
        let width = rhs.width
        let height = rhs.height
        /// 计算最大x/y值
        let maxX = containerWidth - min(width, containerWidth)
        let maxY = containerHeight - min(height, containerHeight)
        /// 确定x/y范围
        guard maxX >= containerMinX, maxY >= containerMinY else { return .zero }
        let xRange = containerMinX...maxX
        let yRange = containerMinY...maxY
        /// 返回约束后的Rect
        return CGRect(x: xRange << x, y: yRange << y, width: width, height: height)
    }
    
    static func +(lhs: CGRect, rhs: UIEdgeInsets) -> CGRect {
        lhs.inset(by: rhs)
    }
}
