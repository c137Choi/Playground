//
//  PHAsset+Rx.swift
//  KnowLED
//
//  Created by Choi on 2024/4/1.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

extension Reactive where Base == PHAsset {
    
    var isInCloud: Single<Bool> {
        let schedular = SerialDispatchQueueScheduler(qos: .userInitiated)
        return Single.create { single in
            let mgr = PHCachingImageManager.default()
            if base.mediaType == .video {
                let videoRequestOptions = PHVideoRequestOptions()
                videoRequestOptions.version = .original
                videoRequestOptions.isNetworkAccessAllowed = false
                mgr.requestAVAsset(forVideo: base, options: videoRequestOptions) { avAsset, audioMix, info in
                    if let info, let isInCloud = info[PHImageResultIsInCloudKey] as? Int {
                        single(.success(isInCloud == 1))
                    } else {
                        single(.success(avAsset.isVoid))
                    }
                }
            } else if base.mediaType == .image {
                let imageRequestOptions = PHImageRequestOptions()
                imageRequestOptions.version = .original
                imageRequestOptions.resizeMode = .none
                imageRequestOptions.isNetworkAccessAllowed = false
                mgr.requestImageDataAndOrientation(for: base, options: imageRequestOptions) { data, string, orientation, info in
                    if let info, let isInCloud = info[PHImageResultIsInCloudKey] as? Int {
                        single(.success(isInCloud == 1))
                    } else {
                        single(.success(data.isVoid))
                    }
                }
            } else {
                single(.success(false))
            }
            return Disposables.create()
        }
        .subscribe(on: schedular)
        .observe(on: MainScheduler.asyncInstance)
    }
    
    /// 获取缩略图
    /// - Parameter targetSize: 缩略图尺寸(单位pt)
    func thumbnail(targetSize: CGSize) -> RxObservable<UIImage> {
        let schedular = SerialDispatchQueueScheduler(qos: .userInitiated)
        return RxObservable.create { observer in
            let mgr = PHCachingImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            /// 后面的block回调可能调用多次,故此方法使用RxObservable初始化
            mgr.requestImage(for: base, targetSize: targetSize.scaledSize, contentMode: .aspectFill, options: option) { uiImage, info in
                guard let uiImage else { return }
                observer.onNext(uiImage)
            }
            return Disposables.create()
        }
        .subscribe(on: schedular)
        .observe(on: MainScheduler.asyncInstance)
    }
}
