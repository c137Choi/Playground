//
//  SizeFixedImageView.swift
//  KnowledPhone
//
//  Created by Choi on 2025/10/11.
//

import UIKit

final class SizeFixedImageView: UIImageView {
    
    /// 固定尺寸
    var fixedSize: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - fixedSize: 固定尺寸
    ///   - image: 图片
    convenience init(size fixedSize: CGSize, image: UIImage? = nil) {
        self.init(image: image)
        self.fixedSize = fixedSize
        self.bounds.size = fixedSize
    }
    
    override var intrinsicContentSize: CGSize {
        fixedSize ?? super.intrinsicContentSize
    }
}
