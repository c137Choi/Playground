//
//  AVPlayer+Rx.swift
//  KnowLED
//
//  Created by Choi on 2024/4/1.
//

import CoreImage
import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base == AVPlayer {
    
    /// 播放AVPlayerItem序列
    var currentItem: Observable<AVPlayerItem?> {
        base.rx.observe(\.currentItem, options: .live)
    }
    
    /// 计算当前进度及当前视频帧数据
    /// - Parameter videoOutput: 视频采集Output
    /// - Parameter preferredFPS: 视频帧率 | 单位: 帧/秒
    func keyFrame(_ videoOutput: AVPlayerItemVideoOutput, preferredFPS: CMTimeScale = 60) -> Observable<AVKeyFrame> {
        currentItem.flatMapLatest { currentItem -> Observable<AVKeyFrame> in
            /// 当前视频
            guard let currentItem else {
                return .empty()
            }
            /// 视频时长
            let duration = currentItem.duration
            /// 关键帧序列
            return Observable.create { observer in
                /// 观测队列
                let queue = DispatchQueue(label: "com.observing.playback", qos: .userInitiated, autoreleaseFrequency: .workItem)
                /// 采样间隔(按60fps计算)
                let interval = CMTime(value: 1, timescale: preferredFPS)
                /// 观察者
                let timeObserver = base.addPeriodicTimeObserver(forInterval: interval, queue: queue) { currentTime in
                    /// CVPixelBuffer
                    guard let cvImageBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else { return }
                    /// -> CIImage
                    let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
                    /// -> CGImage
                    guard let cgImage = CIContext(options: .empty).createCGImage(ciImage, from: ciImage.extent) else { return }
                    /// -> AVKeyFrame
                    let keyFrame = AVKeyFrame(currentTime: currentTime, duration: duration, cgImage: cgImage)
                    /// 发送
                    observer.onNext(keyFrame)
                }
                return Disposables.create {
                    base.removeTimeObserver(timeObserver)
                }
            }
        }
    }
}
