//
//  CAShapeLayer.swift
//  KnowLED
//
//  Created by Choi on 2026/4/30.
//

import UIKit

extension CAShapeLayer {
    
    convenience init(bezierPath: UIBezierPath) {
        self.init(cgPath: bezierPath.cgPath)
    }
    
    convenience init(cgPath: CGPath) {
        self.init()
        self.path = cgPath
    }
}
