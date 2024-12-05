//
//  AVAuthorizationStatusPlus.swift
//
//  Created by Choi on 2022/9/30.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

extension AVAuthorizationStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined:
            return "NOT DETERMINED."
        case .restricted:
            return "RESTRICTED"
        case .denied:
            return localized.alert_CAMERA_ACCESS_DENIED~
        case .authorized:
            return "AUTHORIZED"
        @unknown default:
            return "UNKNOWN STATUS"
        }
    }
}

extension AVAuthorizationStatus: @retroactive LocalizedError {
    
    public var errorDescription: String? {
        description
    }

    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        description
    }

    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        description
    }

    /// A localized message providing "help" text if the user requests help.
    public var helpAnchor: String? {
        description
    }
}

extension AVAuthorizationStatus {
    
    /// 返回可以拍照的权限 | 否则抛出错误
    var validStatus: AVAuthorizationStatus {
        get throws {
            switch self {
            case .notDetermined, .authorized:
                return self
            case .restricted, .denied:
                throw self
            @unknown default:
                fatalError("NEW STATUS NOT HANDLED.")
            }
        }
    }
}

extension AVAuthorizationStatus {
    
    /// 返回可以拍照的权限 | 否则抛出错误
    static var checkValidVideoStatus: Observable<AVAuthorizationStatus> {
        checkVideoStatus.observable.map { status in
            try status.validStatus
        }
    }
    
    /// 检查当前状态并根据当前状态请求权限
    static func checkAndRequestAccess(for mediaType: AVMediaType) -> Observable<AVAuthorizationStatus> {
        currentStatusFor(mediaType).observable.flatMap { currentStatus in
            switch currentStatus {
            case .notDetermined:
                return AVAuthorizationStatus.requestAccess(for: mediaType).observable
            default:
                return Observable.just(currentStatus)
            }
        }
    }
    
    /// 当前相机状态,不请求权限
    static var currentVideoStatus: Infallible<AVAuthorizationStatus> {
        currentStatusFor(.video).asInfallible(onErrorJustReturn: .denied)
    }
    
    /// 查询当前相机权限,如果为第一次请求则请求权限
    static var checkVideoStatus: Infallible<AVAuthorizationStatus> {
        requestAccess(for: .video).asInfallible(onErrorJustReturn: .denied)
    }
    
    /// 查询当前状态,如果为第一次请求则请求权限
    /// - Parameter mediaType: 类型
    /// - Returns: Single<AVAuthorizationStatus>
    static func requestAccess(for mediaType: AVMediaType) -> Single<AVAuthorizationStatus> {
        Single.create { observer in
            let currentStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
            switch currentStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                    /// 注意:这里是非主线程
                    observer(.success(authorized ? .authorized : .denied))
                }
            default:
                observer(.success(currentStatus))
            }
            return Disposables.create()
        }
        .observe(on: MainScheduler.instance)
    }
    
    /// 只查询当前状态,不请求权限
    /// - Parameter mediaType: 类型
    /// - Returns: Single<AVAuthorizationStatus>
    static func currentStatusFor(_ mediaType: AVMediaType) -> Single<AVAuthorizationStatus> {
        Single.just(AVCaptureDevice.authorizationStatus(for: mediaType))
    }
}
