//
//  GCDTimer.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/2/25.
//  Copyright © 2021 Choi. All rights reserved.
//

import Foundation

final class GCDTimer {
	
	typealias GCDTimerClosure = (GCDTimer) -> Void
	
	/// GCD定时器
	private var timerSource: DispatchSourceTimer?
	
	/// 返回有效的定时器
	private var validTimer: DispatchSourceTimer {
		guard let timer = timerSource else {
			let source = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
			source.setEventHandler(handler: tickTock)
			timerSource = source
			return source
		}
		return timer
	}
	
	/// 是否正运行
	private var isTicking = false
	/// 定时器是否有效
	private var isValid: Bool { timerSource != nil }
	
	let timeInterval: DispatchTimeInterval
	let queue: DispatchQueue
	let closure: GCDTimerClosure
	
	/// 定时器初始化方法
	/// - Parameters:
	///   - timeInterval: 时间间隔
	///   - queue: 执行的队列
	///   - closure: 回调闭包
	init(timeInterval: DispatchTimeInterval, queue: DispatchQueue = .main, closure: @escaping GCDTimerClosure) {
		self.timeInterval = timeInterval
		self.queue = queue
		self.closure = closure
	}
	
	/// 创建Timer | 根据延迟时间启动定时器⏲
	/// - Parameters:
	///   - timeInterval: 时间间隔 | .never代表只执行一次
	///   - delay: 延迟时间
	///   - queue: 调用队列
	///   - closure: 回调方法
	/// - Returns: 定时器实列
	@discardableResult
	static func scheduledTimer(
		timeInterval: DispatchTimeInterval = .never,
		delay: DispatchTime = .now(),
		queue: DispatchQueue = .main,
		closure: @escaping GCDTimerClosure)
	-> GCDTimer {
		let timer = self.init(timeInterval: timeInterval, queue: queue, closure: closure)
		timer.fire(delay)
		return timer
	}
	
	/// 定时器调用方法
	private func tickTock() {
		closure(self)
		// 只执行一次
		if timeInterval == .never {
			invalidate()
		}
	}
	
	/// 销毁定时器
	func invalidate() {
		if isValid {
			validTimer.cancel()
			timerSource = .none
			isTicking = false
		}
	}
	
	/// 挂起定时器
	func suspend() {
		if isValid && isTicking {
			validTimer.suspend()
			isTicking = false
		}
	}
	
	/// 继续执行定时器
	func resume() {
		if isValid && !isTicking {
			validTimer.resume()
			isTicking = true
		}
	}
	
	/// 启动定时器
	/// - Parameter delay: 延迟时间
	func fire(_ delay: DispatchTime = .now()) {
		validTimer.schedule(deadline: delay, repeating: timeInterval)
		resume()
	}
	
	deinit {
		invalidate()
	}
}

// MARK: - __________ DispatchTime __________
extension DispatchTime: @retroactive ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Int
	public init(integerLiteral value: Self.IntegerLiteralType) {
		self = .now() + .seconds(value)
	}
}

extension DispatchTime: @retroactive ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Double
	public init(floatLiteral value: Self.FloatLiteralType) {
		let nanoseconds = Int(value * 1_000_000_000)
		self = .now() + .nanoseconds(nanoseconds)
	}
	
	static func seconds(_ seconds: Double) -> DispatchTime {
		self.init(floatLiteral: seconds)
	}
}

// MARK: - __________ DispatchTimeInterval __________
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
