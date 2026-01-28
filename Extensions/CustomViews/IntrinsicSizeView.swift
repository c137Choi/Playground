//
//  IntrinsicSizeView.swift
//  
//
//  Created by Choi on 2021/9/27.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

final class IntrinsicSizeView: UIView {
	
    /// 固定尺寸 | 设置后执行invalidateIntrinsicContentSize
    var intrinsicSize: CGSize? {
        willSet {
            if let newValue {
                bounds.size = newValue
            }
        }
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
	override init(frame: CGRect) {
        super.init(frame: frame)
        self.intrinsicSize = frame.size
	}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override var intrinsicContentSize: CGSize {
        intrinsicSize ?? super.intrinsicContentSize
	}
}
