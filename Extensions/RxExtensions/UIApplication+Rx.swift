//
//  UIApplication+Rx.swift
//
//  Created by Choi on 2022/9/29.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIApplication {
    
    var latestResponderViewAndKeyboardPresentation: RxObservable<(UIView, KeyboardPresentation)> {
        RxObservable.combineLatest(firstResponderView, latestKeyboardPresentation)
    }
    
    var latestKeyboardPresentation: RxObservable<KeyboardPresentation> {
        latestKeyboardNotification.compactMap(KeyboardPresentation.init)
    }
    
    var latestKeyboardNotification: RxObservable<Notification> {
        RxObservable.of(keyboardWillShowNotification, keyboardWillHideNotification).merge()
    }
    
    var keyboardWillShowNotification: RxObservable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
    }
    
    var keyboardDidShowNotification: RxObservable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
    }
    
    var keyboardWillHideNotification: RxObservable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
    }
    
    var keyboardDidHideNotification: RxObservable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
    }
    
    var firstResponderView: RxObservable<UIView> {
        firstResponder.as(UIView.self)
    }
    
    /// 观察当前的第一响应者
    var firstResponder: RxObservable<UIResponder> {
        /// func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool
        methodInvoked(#selector(UIApplication.sendAction))
            .compactMap { args in
                /// 取第三个参数
                guard let thirdParameter = args.element(at: 2) else { return nil }
                /// 如果是手势则返回其view(点击输入框时是一个UITextMultiTapRecognizer手势)
                /// 否则尝试转换为UIResponder再返回
                if let gesture = thirdParameter as? UIGestureRecognizer {
                    return gesture.view
                } else if let regularResponder = thirdParameter as? UIResponder {
                    return regularResponder
                } else {
                    return nil
                }
            }
            .distinctUntilChanged(===)
            .filter(\.isFirstResponder)
    }
}

extension UIApplication {
    
    static var needsUpdate: Driver<Bool> {
        latestRelease.map { release in
            release?.needsUpdate ?? false
        }
    }
    
    static var latestRelease: Driver<Release?> {
        Single.create { observer in
            self.getLatestRelease { release in
                observer(.success(release))
            }
            return Disposables.create()
        }
        .asDriver(onErrorJustReturn: nil)
    }
}
