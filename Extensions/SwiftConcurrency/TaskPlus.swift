//
//  TaskPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/10/16.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    
    static func sleep(_ interval: DispatchTimeInterval) async throws {
        if #available(iOS 16.0, *) {
            try await Task.sleep(for: interval.continuousClockDuration)
        } else {
            try await Task.sleep(nanoseconds: interval.nanoseconds.uInt64)
        }
    }
}

extension Task where Failure == Never {

    @discardableResult
    static func mainActor(name: String? = nil, priority: TaskPriority? = nil, @_implicitSelfCapture operation: @escaping @MainActor @Sendable () async -> Success) -> Self {
        Task(name: name, priority: priority) {
            await operation()
        }
    }
}

extension Task where Failure == any Error {

    @discardableResult
    static func mainActor(name: String? = nil, priority: TaskPriority? = nil, @_implicitSelfCapture operation: @escaping @MainActor @Sendable () async throws -> Success) -> Self {
        Task(name: name, priority: priority) {
            try await operation()
        }
    }
}
