//
//  CGPointPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/7/25.
//

import UIKit
import GLKit

extension CGPoint {
    
    var isZero: Bool {
        self == .zero
    }
    
    /// 计算和另外一个点之间的距离
    func distance(to anotherPoint: CGPoint) -> CGFloat {
        /// hypot: hypotenuse(直角三角形的斜边)
        hypot(x - anotherPoint.x, y - anotherPoint.y)
    }
    
    /// 在两点之间插入点
    /// - Parameters:
    ///   - pointA: 第一个点
    ///   - pointB: 第二个点
    ///   - insertCount: 插入点的数量
    /// - Returns: 当前两点之间新插入的所有点
    static func generatePoints(between pointA: CGPoint, and pointB: CGPoint, insertCount: Int) -> [CGPoint] {
        /// 确保插入数量大于0
        guard insertCount > 0 else { return .empty }
        /// 创建插入点数组
        var points: [CGPoint] = []
        /// 求得xy的偏移
        let dx = pointB.x - pointA.x
        let dy = pointB.y - pointA.y
        /// 求出xy方向上的步进值
        let stepX = dx / insertCount.cgFloat
        let stepY = dy / insertCount.cgFloat
        /// 插入新点
        for i in 1...insertCount {
            let x = pointA.x + i.cgFloat * stepX
            let y = pointA.y + i.cgFloat * stepY
            let point = CGPoint(x: x, y: y)
            points.append(point)
        }
        return points
    }
}

extension CGPoint {
    
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        GLKVector2MultiplyScalar(lhs.glkVector2, rhs.float).cgPoint
    }
    
    var glkVector2: GLKVector2 {
        GLKVector2Make(x.float, y.float)
    }
}

extension GLKVector2 {
    
    var cgPoint: CGPoint {
        CGPoint(x: x.cgFloat, y: y.cgFloat)
    }
}
