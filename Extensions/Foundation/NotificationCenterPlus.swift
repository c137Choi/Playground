//
//  NotificationCenterPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/3/24.
//

import UIKit

extension NotificationCenter {
    
    static func postUserTouch(_ touch: UITouch) {
        NotificationCenter.default.post(name: .userTouch, object: touch)
    }
}
