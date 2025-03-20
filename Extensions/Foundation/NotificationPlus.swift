//
//  NotificationPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/12/16.
//

import Foundation

extension Notification.Name {
    
    /// 通知: 用户是否正在交互
    static let isUserInteracting = Notification.Name.randomUUID
    
    /// 静态变量: 用随机UUID字符串生成一个Notification.Name
    static var randomUUID: Notification.Name {
        Notification.Name(.randomUUID)
    }
}
