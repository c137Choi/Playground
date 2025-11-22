//
//  CADisplayLink+Rx.swift
//  KnowLED
//
//  Created by Choi on 2024/1/19.
//

import UIKit
import RxSwift

public final class RxDisplayLink: ObservableType {
    public typealias Element = CADisplayLink
    
    /// 弱引用RunLoop
    private weak var runloop: RunLoop?
    /// 运行模式
    private let runloopMode: RunLoop.Mode
    /// 帧率范围
    private var frameRateRange: ClosedRange<Float>?
    /// 观察者
    private var observer: AnyObserver<CADisplayLink>?
    
    /// 初始化
    /// - Parameters:
    ///   - runloop: RunLoop
    ///   - mode: RunLoop.Mode
    ///   - frameRateRange: 帧率范围(传空则使用屏幕最大帧率)
    public init(runloop: RunLoop, mode: RunLoop.Mode, frameRateRange: ClosedRange<Float>? = nil) {
        self.runloop = runloop
        self.runloopMode = mode
        self.frameRateRange = frameRateRange
    }
    
    @objc private func nextFrame(_ sender: CADisplayLink) {
        observer?.onNext(sender)
    }
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == CADisplayLink {
        if let runloop {
            /// 转换成AnyObserver
            self.observer = AnyObserver(observer)
            /// 这里target会强引用self
            let displayLink = CADisplayLink(target: self, selector: #selector(nextFrame))
            /// 添加至RunLoop
            displayLink.add(to: runloop, forMode: runloopMode)
            /// 设置帧率
            if #available(iOS 15.0, *) {
                displayLink.preferredFrameRateRange = frameRateRange.map(fallback: .default) {
                    CAFrameRateRange(minimum: $0.lowerBound, maximum: $0.upperBound)
                }
            } else {
                displayLink.preferredFramesPerSecond = frameRateRange.map(fallback: 0, \.upperBound.int)
            }
            return Disposables.create(with: displayLink.invalidate)
        } else {
            return Disposables.create()
        }
    }
    
    public convenience init(runloop: RunLoop = .main, mode: RunLoop.Mode = .common, framesPerSecond: Int? = nil) {
        let frameRateRange = framesPerSecond.flatMap { frameRate in
            try? ClosedRange(lowerBound: frameRate.float, upperBound: frameRate.float)
        }
        self.init(runloop: runloop, mode: mode, frameRateRange: frameRateRange)
    }
}
