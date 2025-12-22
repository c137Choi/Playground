//
//  IntrinsicSizeImageView.swift
//  KnowledPhone
//
//  Created by Choi on 2025/10/11.
//

import UIKit

final class IntrinsicSizeImageView: UIImageView {
    
    /// 固定尺寸
    var intrinsicSize: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - size: 固定尺寸
    ///   - image: 图片
    convenience init(size: CGSize, image: UIImage?) {
        self.init(image: image)
        self.bounds.size = size
        self.intrinsicSize = size
    }
    
    override var intrinsicContentSize: CGSize {
        intrinsicSize ?? super.intrinsicContentSize
    }
}
