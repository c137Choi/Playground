//
//  SizeFixedView.swift
//  
//
//  Created by Choi on 2021/9/27.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

final class SizeFixedView: UIView {
    
    /// 固定尺寸
    var fixedSize: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 初始化
    /// - Parameter fixedSize: 固定尺寸
	convenience init(_ fixedSize: CGSize) {
        let initialFrame = CGRect(origin: .zero, size: fixedSize)
        self.init(frame: initialFrame)
        self.fixedSize = fixedSize
	}
	
	override init(frame: CGRect) {
        super.init(frame: frame)
        self.fixedSize = frame.size
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override var intrinsicContentSize: CGSize {
        fixedSize ?? super.intrinsicContentSize
	}
}
