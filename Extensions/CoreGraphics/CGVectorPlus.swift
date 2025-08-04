//
//  CGVectorPlus.swift
//
//  Created by Choi on 2022/8/26.
//

import CoreGraphics

extension CGVector {
    
    static func +(lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    static func +=(lhs: inout CGVector, rhs: CGVector) {
        lhs.dx += rhs.dx
        lhs.dy += rhs.dy
    }
    prefix static func +(value: CGVector) -> CGVector {
        CGVector(dx: value.dx.magnitude, dy: value.dy.magnitude)
    }
    
    static func -(lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    static func -=(lhs: inout CGVector, rhs: CGVector) {
        lhs.dx -= rhs.dx
        lhs.dy -= rhs.dy
    }
    prefix static func -(value: CGVector) -> CGVector {
        CGVector(dx: -value.dx, dy: -value.dy)
    }
    
    static func *(lhs: CGVector, rhs: CGVector) -> Double {
        lhs.dx * rhs.dx + lhs.dy * rhs.dy
    }
    static func *=(lhs: inout CGVector, value: Double) {
        lhs.dx *= value
        lhs.dy *= value
    }
    static func *(lhs: CGVector, value: Double) -> CGVector {
        CGVector(dx: lhs.dx * value, dy: lhs.dy * value)
    }
}

extension CGVector {
    static var up: CGVector {
        CGVector(dx: 0, dy: -1)
    }
    static var down: CGVector {
        CGVector(dx: 0, dy: 1)
    }
    static var left: CGVector {
        CGVector(dx: -1, dy: 0)
    }
    static var right: CGVector {
        CGVector(dx: 1, dy: 0)
    }
    static var topRight: CGVector {
        up + right
    }
    static var bottomRight: CGVector {
        down + right
    }
    static var topLeft: CGVector {
        up + left
    }
    static var bottomLeft: CGVector {
        down + left
    }
}

extension CGVector {
    
    var positivePoints: (start: CGPoint, end: CGPoint) {
        var start = CGPoint.zero
        var end = cgPoint
        if dx < 0 {
            start.x += dx.magnitude
            end.x += dx.magnitude
        }
        if dy < 0 {
            start.y += dy.magnitude
            end.y += dy.magnitude
        }
        return (start, end)
    }
    
    var cgPoint: CGPoint {
        CGPoint(x: dx, y: dy)
    }
}
