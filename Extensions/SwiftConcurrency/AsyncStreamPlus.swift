//
//  AsyncStreamPlus.swift
//  KnowLED
//
//  Created by Choi on 2026/6/10.
//

import Foundation
import Combine
import RxSwift

nonisolated extension AsyncStream {
    
    static var empty: AsyncStream<Element> {
        AsyncStream<Element> { continuation in
            continuation.finish()
        }
    }
}

nonisolated extension AsyncStream where Element: FixedWidthInteger {
    
    static func timer(milliseconds: Int) -> AsyncStream<Element> {
        timer(period: .milliseconds(milliseconds))
    }
    
    /// AsyncStream定时器
    /// - Parameters:
    ///   - dueTime: 执行前等待时间
    ///   - period: 定时器间隔
    /// - Returns: AsyncStream<Element>
    static func timer(period: RxTimeInterval?) -> AsyncStream<Element> {
        SerialDispatchQueueScheduler(qos: .userInitiated).transform { scheduler in
            Observable<Element>.timer(0, period: period, scheduler: scheduler)
                .asInfallible(onErrorJustReturn: 0)
                .values
        }
    }
}
