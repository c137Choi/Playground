//
//  NotificationPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/12/16.
//

import UIKit

extension Notification.Name {
    
    /// (用户交互)通知
    static let touchPhase = Notification.Name.randomUUID
    
    /// 静态变量: 用随机UUID字符串生成一个Notification.Name
    static var randomUUID: Notification.Name {
        Notification.Name(.randomUUID)
    }
}

extension NotificationCenter {
    
    static func post(touchPhase: UITouch.Phase, in view: UIView?) {
        let snapshot = TouchPhaseSnapshot(phase: touchPhase, view: view)
        NotificationCenter.default.post(name: .touchPhase, object: snapshot)
    }
}
