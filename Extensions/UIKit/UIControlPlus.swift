//
//  UIControlPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/9.
//

import UIKit

extension UIControl {
    
    var isDisabled: Bool {
        get { !isEnabled }
        set(disabled) { isEnabled = !disabled }
    }
}
