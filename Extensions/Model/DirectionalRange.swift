//
//  DirectionalRange.swift
//  KnowLED
//
//  Created by Choi on 2024/2/29.
//

import Foundation

enum RangeDirection: Int {
    case forward = 0
    case backward
}
extension RangeDirection: RawRepresentable {}
extension RangeDirection: CustomDebugStringConvertible {
    var debugDescription: String {
        self == .forward ? "正向" : "反向"
    }
}

/// ClosedRange套壳
/// 加了一个方向属性,根据此属性在调用(*)运算符乘以百分比时决定最终值的结果
struct DirectionalRange<Bound>: Equatable where Bound: Comparable {
    var direction: RangeDirection
    var range: ClosedRange<Bound>
}

extension DirectionalRange {
    
    /// 根据起止值初始化
    init(from start: Bound, to end: Bound) {
        self.direction = end >= start ? .forward : .backward
        self.range = min(start, end)...max(start, end)
    }
    
    init(range: ClosedRange<Bound>) {
        self.direction = .forward
        self.range = range
    }
}

extension DirectionalRange: CustomDebugStringConvertible {
    
    var debugDescription: String {
        "\(direction.debugDescription), 范围: \(range.description)"
    }
}

extension DirectionalRange where Bound: BinaryFloatingPoint {
    
    /// 计算范围和百分比相乘之后得出范围内的值
    /// - Parameters:
    ///   - lhs: 闭合范围
    ///   - rhs: 百分比: 0...1.0
    /// - Returns: 范围内的值
    static func * (lhs: Bound, rhs: Self) -> Bound { rhs * lhs }
    static func * (lhs: Self, rhs: Bound) -> Bound {
        let percent = switch lhs.direction {
        case .forward:
            Bound.hotPercentRange << rhs
        case .backward:
            1.0 - (Bound.hotPercentRange << rhs)
        }
        return lhs.range * percent
    }
}

extension DirectionalRange where Bound: BinaryInteger {
    
    /// 计算范围和百分比相乘之后得出范围内的值
    /// - Parameters:
    ///   - lhs: 闭合范围
    ///   - rhs: 百分比: 0...1.0
    /// - Returns: 范围内的值
    static func * (lhs: Double, rhs: Self) -> Bound { rhs * lhs }
    static func * (lhs: Self, rhs: Double) -> Bound {
        let percent = switch lhs.direction {
        case .forward:
            Double.percentRange << rhs
        case .backward:
            1.0 - (Double.percentRange << rhs)
        }
        return lhs.range * percent
    }
}
