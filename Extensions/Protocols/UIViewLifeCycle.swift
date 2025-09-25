//
//  UIViewLifeCycle.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

protocol UIViewLifeCycle: UIView {
    
    func prepare()
    
    func prepareSubviews()
    
    func prepareConstraints()
}

extension UIViewLifeCycle {
    
    func prepare() {
        prepareSubviews()
        prepareConstraints()
    }
}
