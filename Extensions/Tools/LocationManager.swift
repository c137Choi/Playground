//
//  LocationManager.swift
//  KnowLED
//
//  Created by Choi on 2023/10/21.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {
    /// 单例对象
    static let shared = LocationManager()
    /// 定位管理器核心对象
    let core = CLLocationManager()
    /// 定位权限
    fileprivate lazy var authorizationStatusRelay = BehaviorRelay(value: core.compatibleAuthorizationStatus)
    
    private override init() {
        super.init()
        /// 设置代理
        core.delegate = self
    }
}

extension LocationManager {
    
    var authorizationStatus: CLAuthorizationStatus {
        get { authorizationStatusRelay.value }
        set { authorizationStatusRelay << newValue }
    }
    
    /// 请求位置权限
    static func requestAuthorizationIfNeeded() {
        guard let infoDictionary = Bundle.main.infoDictionary else { return }
        lazy var infoKeys = infoDictionary.keys
        let core = LocationManager.shared.core
        if core.compatibleAuthorizationStatus.isNotDetermined {
            if infoKeys.contains(.whenInUseUsageDescriptionKey) {
                core.requestWhenInUseAuthorization()
            } else if infoKeys.contains(.alwaysAndWhenInUseUsageDescriptionKey) || infoKeys.contains(.alwaysUsageDescriptionKey) {
                core.requestAlwaysAuthorization()
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            authorizationStatus = manager.authorizationStatus
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #unavailable(iOS 14.0) {
            authorizationStatus = status
        }
    }
}

extension Reactive where Base == LocationManager {
    
    /// 位置权限序列
    static var authorizationStatus: Observable<CLAuthorizationStatus> {
        authorizationStatus(requestOnSubscribe: true)
    }
    
    /// 位置权限序列
    /// - Parameter requestOnSubscribe: 订阅时是否立刻请求位置权限
    /// - Returns: 位置权限序列
    static func authorizationStatus(requestOnSubscribe: Bool) -> Observable<CLAuthorizationStatus> {
        let unwrappedStatus = LocationManager.shared.authorizationStatusRelay
        if requestOnSubscribe {
            return unwrappedStatus.do(onSubscribe: LocationManager.requestAuthorizationIfNeeded)
        } else {
            return unwrappedStatus.asObservable()
        }
    }
}

fileprivate extension String {
    static let alwaysAndWhenInUseUsageDescriptionKey = "NSLocationAlwaysAndWhenInUseUsageDescription"
    static let alwaysUsageDescriptionKey = "NSLocationAlwaysUsageDescription"
    static let whenInUseUsageDescriptionKey = "NSLocationWhenInUseUsageDescription"
    static let usageDescriptionKey = "NSLocationUsageDescription"
    static let temporaryUsageDescriptionDictionaryKey = "NSLocationTemporaryUsageDescriptionDictionary"
}
