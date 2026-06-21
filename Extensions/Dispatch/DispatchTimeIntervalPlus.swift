//
//  DispatchTimeIntervalPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/7/19.
//

import Foundation

extension DispatchTimeInterval {
    
    @available(iOS 16.0, *)
    var continuousClockDuration: ContinuousClock.Duration {
        switch self {
        case .seconds(let seconds):
            ContinuousClock.Duration.seconds(seconds)
        case .milliseconds(let milliseconds):
            ContinuousClock.Duration.milliseconds(milliseconds)
        case .microseconds(let microseconds):
            ContinuousClock.Duration.microseconds(microseconds)
        case .nanoseconds(let nanoseconds):
            ContinuousClock.Duration.nanoseconds(nanoseconds)
        default:
            ContinuousClock.Duration.nanoseconds(0)
        }
    }
    
    /// 转换成纳秒
    var nanoseconds: Int {
        switch self {
        case .seconds(let seconds):
            seconds * 1_000_000_000
        case .milliseconds(let milliseconds):
            milliseconds * 1_000_000
        case .microseconds(let microseconds):
            microseconds * 1_000
        case .nanoseconds(let nanoseconds):
            nanoseconds
        default:
            0
        }
    }
}

extension DispatchTimeInterval: @retroactive ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public init(integerLiteral value: Self.IntegerLiteralType) {
        self = .seconds(value)
    }
}

extension DispatchTimeInterval: @retroactive ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public init(floatLiteral value: Self.FloatLiteralType) {
        let nanoseconds = Int(value * 1_000_000_000)
        self = .nanoseconds(nanoseconds)
    }
}
