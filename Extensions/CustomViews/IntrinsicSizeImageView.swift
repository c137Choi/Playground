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
        willSet {
            if let newValue {
                bounds.size = newValue
            }
        }
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - width: 固定宽度
    ///   - height: 固定高度
    ///   - image: 初始图片
    convenience init(width: CGFloat, height: CGFloat, image: UIImage?) {
        let size = CGSize(width: width, height: height)
        self.init(size: size, image: image)
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
