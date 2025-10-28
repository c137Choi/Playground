//
//  UIDevice+Rx.swift
//  KnowLED
//
//  Created by Choi on 2023/10/7.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base == UIDevice {
    
    /// 设备是否横屏
    /// 结合Size.screenSize方法, 可以映射出当前朝向的屏幕尺寸. e.g. isLandscape.map(Size.screenSize)
    static var isLandscape: RxObservable<Bool> {
        orientation
            .map(\.isScreenLandscape)
            .removeDuplicates
    }
    
    static var orientation: RxObservable<UIDeviceOrientation> {
        /// 注: 不要再.do(onDispose: UIDevice.current.endGeneratingDeviceOrientationNotifications)
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .map(\.object)
            .asOptional(UIDevice.self)
            .unwrapped
            .map(\.orientation)
            .startWith(UIDevice.current.orientation)
            .do(onSubscribe: UIDevice.current.beginGeneratingDeviceOrientationNotifications)
    }
    
}
