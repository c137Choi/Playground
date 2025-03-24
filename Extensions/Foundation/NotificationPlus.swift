//
//  NotificationPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/12/16.
//

import Foundation

extension Notification.Name {
    
    /// 通知: UITouch对象
    static let userTouch = Notification.Name.randomUUID
    
    /// 静态变量: 用随机UUID字符串生成一个Notification.Name
    static var randomUUID: Notification.Name {
        Notification.Name(.randomUUID)
    }
}
