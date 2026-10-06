//
//  UIBarButtonItemPlus.swift
//  KnowLED
//
//  Created by Choi on 2026/10/6.
//

import UIKit

extension Configurable where Self: UIBarButtonItem {
    
    /// 隐藏毛玻璃效果
    var withoutSharedBackground: Self {
        if #available(iOS 26.0, *) {
            hidesSharedBackground = true
        }
        return self
    }
}
