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
                    /// 当前帧的CGImage
                    guard let cgImage = cgImage(videoOutput, at: currentTime) else { return }
                    /// 创建关键帧
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
    
    /// 当前时间的CGImage对象 | 宽高尺寸为视频源数据帧的宽高
    private func cgImage(_ videoOutput: AVPlayerItemVideoOutput, at time: CMTime) -> CGImage? {
        guard let cvImageBuffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return nil }
        let ciContextOptions: [CIContextOption: Any] = [:]
        let ciContext = CIContext(options: ciContextOptions)
        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        return cgImage
    }
    
    /// 播放AVPlayerItem序列
    var currentItem: Observable<AVPlayerItem?> {
        base.rx.observe(\.currentItem, options: .live)
    }
}
