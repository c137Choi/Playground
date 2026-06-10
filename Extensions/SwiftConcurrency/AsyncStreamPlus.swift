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
    ///   - period: 定时器间隔. 如果为空则只发送一个元素
    ///   - dueTime: 执行前等待时间
    /// - Returns: AsyncStream<Element>
    static func timer(period: RxTimeInterval? = nil, dueTime: RxTimeInterval = 0) -> AsyncStream<Element> {
        SerialDispatchQueueScheduler(qos: .userInitiated).transform { scheduler in
            Observable<Element>.timer(dueTime, period: period, scheduler: scheduler)
                .asInfallible(onErrorJustReturn: 0)
                .values
        }
    }
}
