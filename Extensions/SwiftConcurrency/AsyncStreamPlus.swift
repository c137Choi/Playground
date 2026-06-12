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
    
    /// AsyncStream定时器
    /// - Parameters:
    ///   - dueTime: 执行前等待时间
    ///   - period: 定时器间隔
    /// - Returns: AsyncStream<Element>
    nonisolated static func timer(dueTime: RxTimeInterval = 0, period: RxTimeInterval?) -> AsyncStream<Element> {
        SerialDispatchQueueScheduler(qos: .userInitiated).transform { scheduler in
            Observable<Element>.timer(dueTime, period: period, scheduler: scheduler)
                .asInfallible(onErrorJustReturn: 0)
                .values
        }
    }
}
