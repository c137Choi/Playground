//
//  AutoResizeCollectionView.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/9/16.
//  Copyright © 2021 Choi. All rights reserved.
//
//  高度/宽度自增长的CollectionView. 要事先约束好宽/高

import UIKit

class AutoResizeCollectionView: UICollectionView {
    
	override var contentSize: CGSize {
		get { super.contentSize }
		set { super.contentSize = newValue
			invalidateIntrinsicContentSize()
		}
	}
    
	override var intrinsicContentSize: CGSize { contentSize }
}
