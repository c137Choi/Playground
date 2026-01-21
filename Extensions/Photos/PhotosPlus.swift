//
//  PhotosPlus.swift
//
//  Created by Choi on 2022/8/16.
//

import Photos
import PhotosUI
import RxSwift
import RxCocoa

extension PHAuthorizationStatus: @retroactive _BridgedNSError {}
extension PHAuthorizationStatus: @retroactive _ObjectiveCBridgeableError {}
extension PHAuthorizationStatus: @retroactive LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .notDetermined:
            return "NOT DETERMINED."
        case .restricted:
            return "RESTRICTED"
        case .denied:
            return String(localized: "相册未授权")
        case .authorized:
            return "AUTHORIZED"
        case .limited:
            return "LIMITED"
        @unknown default:
            return "UNKNOWN STATUS"
        }
    }

    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        switch self {
        case .notDetermined:
            return "NOT DETERMINED."
        case .restricted:
            return "RESTRICTED"
        case .denied:
            return "DENIED"
        case .authorized:
            return "AUTHORIZED"
        case .limited:
            return "LIMITED"
        @unknown default:
            return "UNKNOWN STATUS"
        }
    }

    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        switch self {
        case .notDetermined:
            return "NOT DETERMINED."
        case .restricted:
            return "RESTRICTED"
        case .denied:
            return "DENIED"
        case .authorized:
            return "AUTHORIZED"
        case .limited:
            return "LIMITED"
        @unknown default:
            return "UNKNOWN STATUS"
        }
    }

    /// A localized message providing "help" text if the user requests help.
    public var helpAnchor: String? {
        switch self {
        case .notDetermined:
            return "NOT DETERMINED."
        case .restricted:
            return "RESTRICTED"
        case .denied:
            return "DENIED"
        case .authorized:
            return "AUTHORIZED"
        case .limited:
            return "LIMITED"
        @unknown default:
            return "UNKNOWN STATUS"
        }
    }
}

extension PHAuthorizationStatus {
    
    /// 返回可以拿到图片的权限 | 否则抛出错误
    var validStatus: PHAuthorizationStatus {
        get throws {
            switch self {
            case .notDetermined, .authorized, .limited:
                return self
            case .restricted, .denied:
                throw self
            @unknown default:
                fatalError("NEW STATUS NOT HANDLED.")
            }
        }
    }
}

extension PHPhotoLibrary {
    
    static var validReadWriteAuthorizationStatus: Single<PHAuthorizationStatus> {
        readWriteAuthorizationStatus.map { status in
            try status.validStatus
        }
    }
    
    /// 检查或请求相册权限
    static var readWriteAuthorizationStatus: Single<PHAuthorizationStatus> {
        Single.create { observer in
            let authorization = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch authorization {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { updatedStatus in
                    observer(.success(updatedStatus))
                }
            default:
                observer(.success(authorization))
            }
            return Disposables.create()
        }
        .observe(on: MainScheduler.instance)
    }
}
