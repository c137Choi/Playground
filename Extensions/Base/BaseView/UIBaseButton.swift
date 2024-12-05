//
//  UIBaseButton.swift
//
//  Created by Choi on 2022/9/5.
//

import UIKit

extension UIButton.State: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

class UIBaseButton: UIButton {

    private var backgroundColorForState: [UIButton.State: UIColor] = [:]
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refillColors()
    }
}

extension UIBaseButton {
    
    func refillColors() {
        backgroundColor = backgroundColorForState[state] ?? backgroundColorForState[.normal]
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColorForState[state] = color
        refillColors()
    }
}
