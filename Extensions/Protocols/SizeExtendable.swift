//
//  SizeExtendable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

protocol SizeExtendable {
    
    /// 垂直方向扩展
    var vertical: CGFloat { get }
    
    /// 水平方向扩展
    var horizontal: CGFloat { get }
}

extension Int: SizeExtendable {
    var vertical: CGFloat { cgFloat }
    var horizontal: CGFloat { cgFloat }
}

extension Double: SizeExtendable {
    var vertical: CGFloat { self }
    var horizontal: CGFloat { self }
}

extension CGSize: SizeExtendable {
    var vertical: CGFloat { height }
    var horizontal: CGFloat { width }
}

extension UIEdgeInsets: SizeExtendable {
    
    var vertical: CGFloat {
        get { top + bottom }
        set { top = newValue; bottom = newValue }
    }
    
    var horizontal: CGFloat {
        get { left + right }
        set { left = newValue; right = newValue }
    }
}
