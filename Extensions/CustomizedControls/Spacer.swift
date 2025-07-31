//
//  Spacer.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/8/2.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

final class Spacer: UIView {
	private let intrinsicWidth: CGFloat?
	private let intrinsicHeight: CGFloat?
    
	init(intrinsicWidth: CGFloat? = nil, intrinsicHeight: CGFloat? = nil) {
		self.intrinsicWidth = intrinsicWidth
		self.intrinsicHeight = intrinsicHeight
        let initialSize = CGSize(width: intrinsicWidth.orZero, height: intrinsicHeight.orZero)
		let initialFrame = CGRect(origin: .zero, size: initialSize)
		super.init(frame: initialFrame)
	}
    
    override init(frame: CGRect) {
        intrinsicWidth = nil
        intrinsicHeight = nil
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { nil }
    
	override var intrinsicContentSize: CGSize {
		var intrinsicSize = UIView.layoutFittingExpandedSize
		if let intrinsicWidth {
			intrinsicSize.width = intrinsicWidth
		}
		if let height = intrinsicHeight {
			intrinsicSize.height = height
		}
		return intrinsicSize
	}
}
