//
//  NotificationPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/12/16.
//

import Foundation

extension Notification.Name {
    static var make: Notification.Name {
        Notification.Name(.randomUUID)
    }
}
