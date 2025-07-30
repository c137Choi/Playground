//
//  NotificationPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/12/16.
//

import UIKit

extension Notification.Name {
    /// 静态变量: 用随机UUID字符串生成一个Notification.Name
    static var randomUUID: Notification.Name {
        Notification.Name(.randomUUID)
    }
}
