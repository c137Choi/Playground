//
//  Task+Rx.swift
//  KnowLED
//
//  Created by Choi on 2026/6/11.
//

import RxSwift

nonisolated extension Task: @retroactive Disposable {
    public func dispose() {
        cancel()
    }
}
