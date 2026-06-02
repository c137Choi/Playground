//
//  KeyboardPresentation.swift
//
//  Created by Choi on 2022/10/20.
//

import UIKit

struct KeyboardPresentation {
    let state: State
    let fromRect: CGRect
    let toRect: CGRect
    let animationDuration: TimeInterval
    let animationCurve: UIView.AnimationCurve
    init?(_ notification: Notification) {
        /// 判断键盘状态
        if notification.name == UIResponder.keyboardWillShowNotification {
            state = .presenting
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            state = .dismissing
        } else {
            return nil
        }
        
        guard let userInfo = notification.userInfo else { return nil }
        
        /// NSValue of CGRect
        guard let keyboardFrameBegin = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return nil }
        self.fromRect = keyboardFrameBegin.cgRectValue
        
        /// NSValue of CGRect
        guard let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return nil }
        self.toRect = keyboardFrameEnd.cgRectValue
        
        /// NSNumber of double
        guard let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return nil }
        self.animationDuration = keyboardAnimationDuration.doubleValue
        
        /// NSNumber of NSUInteger (UIViewAnimationCurve)
        guard
            let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve.intValue)
        else {
            return nil
        }
        self.animationCurve = animationCurve
    }
}

extension KeyboardPresentation {
    enum State {
        case presenting
        case dismissing
    }
}

extension KeyboardPresentation {
    
    /// 根据键盘显示/隐藏调整相应父视图的坐标
    /// - Parameters:
    ///   - type: 父视图的类型
    ///   - firstResponder: 第一响应者
    func adjustBoundsOfSuperview<Superview: UIView>(type: Superview.Type, firstResponder: UIView?) {
        guard let firstResponder else { return }
        guard let superview = firstResponder.superview(type) else { return }
        adjustBoundsOfSuperview(superview, firstResponder: firstResponder)
    }
    
    
    /// 根据键盘显示/隐藏调整相应父视图的坐标
    /// - Parameters:
    ///   - superview: 要调整bounds的父视图
    ///   - firstResponder: 第一响应者
    func adjustBoundsOfSuperview(_ superview: UIView?, firstResponder: UIView?) {
        guard let firstResponder else { return }
        guard let superview else { return }
        switch state {
        case .presenting:
            /// 自定义值: 键盘顶部间距
            let padding = 0.0
            /// 键盘顶部的Y值 - 键盘顶部间距
            let keyboardTolerance = toRect.minY - padding
            let extraPadding = firstResponder.frameInWindow.maxY - keyboardTolerance
            if extraPadding > 0 {
                superview.bounds.origin.y = extraPadding
            }
        case .dismissing:
            superview.bounds.origin.y = 0
        }
    }
}
