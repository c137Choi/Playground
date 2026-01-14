//
//  UIButtonType.swift
//  KnowLED
//
//  Created by Choi on 2026/1/14.
//

import UIKit

protocol UIButtonType: UIButton {}

extension UIButton: UIButtonType {}

extension UIButtonType {
    
    static func filled(_ configSetup: UIButtonConfigurationSetup) -> Self {
        UIButton.Configuration.filled(configSetup).transform {
            self.init(frame: .zero).with(new: \.configuration, $0)
        }
    }
}
