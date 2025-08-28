//
//  UIApplication+Rx.swift
//
//  Created by Choi on 2022/9/29.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIApplication {
    
    var latestResponderViewAndKeyboardPresentation: Observable<(UIView, KeyboardPresentation)> {
        Observable.combineLatest(firstResponderView, latestKeyboardPresentation)
    }
    
    var latestKeyboardPresentation: Observable<KeyboardPresentation> {
        latestKeyboardNotification.compactMap(KeyboardPresentation.init)
    }
    
    var latestKeyboardNotification: Observable<Notification> {
        Observable.of(keyboardWillShowNotification, keyboardWillHideNotification).merge()
    }
    
    var keyboardWillShowNotification: Observable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
    }
    
    var keyboardDidShowNotification: Observable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
    }
    
    var keyboardWillHideNotification: Observable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
    }
    
    var keyboardDidHideNotification: Observable<Notification> {
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
    }
    
    var firstResponderView: Observable<UIView> {
        firstResponder.as(UIView.self)
    }
    
    /// 观察当前的第一响应者
    var firstResponder: Observable<UIResponder> {
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
