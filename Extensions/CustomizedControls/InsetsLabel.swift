//
//  InsetsLabel.swift
//  ExtensionDemo
//
//  Created by Choi on 2020/11/4.
//  Copyright © 2020 Choi. All rights reserved.
//

import UIKit

class InsetsLabel: UILabel {
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: textEdgeInsets)
        let rect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        return rect.inset(by: textEdgeInsets.reversed)
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textEdgeInsets)
        super.drawText(in: insetRect)
    }
    
    /// 文字内边距
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
}
