//
//  GCDTimer.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/2/25.
//  Copyright © 2021 Choi. All rights reserved.
//

import Foundation

final class GCDTimer {
	
    /// 定时器回调
	typealias TickTock = (GCDTimer) -> Void
    
    /// 定时器状态
    enum State {
        /// 起始状态/计时器销毁状态
        case initial
        /// 运行中
        case running
        /// 挂起中
        case suspended
    }
	
    /// 定时器回调间隔
	let timeInterval: DispatchTimeInterval
    /// 执行队列
	let queue: DispatchQueue
    /// 供外部使用的定时器回调
	let tickTock: TickTock
    /// GCD定时器
    private var _timer: DispatchSourceTimer?
    /// 状态
    private var state = State.initial
    /// 返回定时器 | 如果不存在则创建一个并存入属性中以便后续使用
    private var timer: DispatchSourceTimer {
        guard let existingTimer = _timer else {
            let babyTimer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
            babyTimer.setEventHandler(handler: timerTicking)
            _timer = babyTimer
            return babyTimer
        }
        return existingTimer
    }
	/// 定时器初始化方法
	/// - Parameters:
	///   - timeInterval: 时间间隔
	///   - queue: 执行的队列
	///   - tickTock: 回调闭包
	init(timeInterval: DispatchTimeInterval, queue: DispatchQueue = .main, tickTock: @escaping TickTock) {
		self.timeInterval = timeInterval
		self.queue = queue
		self.tickTock = tickTock
	}
	
	/// 创建Timer | 根据延迟时间启动定时器⏲
	/// - Parameters:
	///   - timeInterval: 时间间隔 | .never代表只执行一次
	///   - delay: 延迟时间
	///   - queue: 调用队列
	///   - tickTock: 回调方法
	/// - Returns: 定时器实列
	@discardableResult
	static func scheduledTimer(
		timeInterval: DispatchTimeInterval = .never,
		delay: DispatchTime = .now(),
		queue: DispatchQueue = .main,
        tickTock: @escaping TickTock)
	-> GCDTimer {
		let timer = self.init(timeInterval: timeInterval, queue: queue, tickTock: tickTock)
		timer.fire(delay)
		return timer
	}
    
    /// 定时器调用方法
    private var timerTicking: DispatchWorkItem {
        DispatchWorkItem {
            [weak self] in
            guard let self else { return }
            /// 执行回调
            tickTock(self)
            /// 只执行一次
            if timeInterval == .never {
                invalidate()
            }
        }
    }
    
    /// 开启/继续执行定时器
    func resume() {
        if let timer = _timer, state != .running {
            timer.resume()
            state = .running
        }
    }
	
	/// 挂起定时器
    func suspend() {
        if let timer = _timer, state == .running {
			timer.suspend()
            state = .suspended
		}
	}
    
    /// 销毁定时器
    func invalidate() {
        guard let timer = _timer else { return }
        /// 如果为挂起状态, 则需要先开启再销毁, 否则会导致崩溃
        if state == .suspended {
            timer.resume()
        }
        timer.cancel()
        _timer = .none
        state = .initial
    }
	
	/// 启动定时器
	/// - Parameter delay: 延迟时间
	func fire(_ delay: DispatchTime = .now()) {
		timer.schedule(deadline: delay, repeating: timeInterval)
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
