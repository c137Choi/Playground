//
//  AsyncStreamPlus.swift
//  KnowLED
//
//  Created by Choi on 2026/6/10.
//

import Foundation

nonisolated extension AsyncStream {
    
    static var empty: AsyncStream<Element> {
        AsyncStream<Element> { continuation in
            continuation.finish()
        }
    }
}

nonisolated extension AsyncStream where Element: FixedWidthInteger {
    
    /// AsyncStream定时器
    static func timer(milliseconds: Int, bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .bufferingNewest(1)) -> AsyncStream<Element> {
        AsyncStream<Element>(bufferingPolicy: bufferingPolicy) { continuation in
            let task = Task(priority: .userInitiated) {
                /// 计数值(按元素位宽回绕循环: 如UInt8发出0...255)
                var value: Element = 0
                /// 首个元素立即产出
                continuation.yield(value)
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
                    value = value &+ 1
                    continuation.yield(value)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
