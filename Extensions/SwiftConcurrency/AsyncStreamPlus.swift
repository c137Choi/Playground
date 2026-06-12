//
//  AsyncStreamPlus.swift
//  KnowLED
//
//  Created by Choi on 2026/6/10.
//

import Foundation
import Combine
import RxSwift

extension AsyncStream where Element: FixedWidthInteger {
    
    nonisolated static func timer(milliseconds: Int) -> AsyncStream<Element> {
        timer(period: .milliseconds(milliseconds))
    }
    
    /// AsyncStream定时器
    /// - Parameters:
    ///   - dueTime: 执行前等待时间
    ///   - period: 定时器间隔
    /// - Returns: AsyncStream<Element>
    nonisolated static func timer(period: RxTimeInterval?) -> AsyncStream<Element> {
        SerialDispatchQueueScheduler(qos: .userInitiated).transform { scheduler in
            Observable<Element>.timer(0, period: period, scheduler: scheduler)
                .asInfallible(onErrorJustReturn: 0)
                .values
        }
    }
}
