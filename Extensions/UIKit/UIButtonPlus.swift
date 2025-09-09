//
//  ExtensionButton.swift
//  
//
//  Created by Choi on 2020/7/22.
//

import UIKit

extension UIButton {
    
    enum Associated {
        @UniqueAddress static var imagePlacement
        @UniqueAddress static var imagePadding
    }
    
    convenience init(image: UIImage?) {
        self.init(frame: .zero)
        setImage(image, for: .normal)
    }
    
    convenience init(title: String? = nil, titleColor: UIColor? = nil, titleFontSize: CGFloat = 14.0, titleFontWeight: UIFont.Weight = .regular) {
        let font = UIFont.systemFont(ofSize: titleFontSize, weight: titleFontWeight)
        self.init(title: title, titleColor: titleColor, font: font)
    }
    
    convenience init(title: String? = nil, titleColor: UIColor? = nil, font: UIFont) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
    }
    
    var titleFont: UIFont? {
        get { titleLabel?.font }
        set { titleLabel?.font = newValue }
    }
	
    private var imageWidth: CGFloat { imageSize.width }
    private var imageHeight: CGFloat { imageSize.height }
    private var titleWidth: CGFloat { titleSize.width }
    private var titleHeight: CGFloat { titleSize.height }
    
    private var imageSize: CGSize {
        currentImage.or(.zero, map: \.size)
    }
    
	private var titleSize: CGSize {
		/// 适配iOS14,否则此属性会按照字体的Font返回一个值,从而影响intrinsicContentSize的计算
		guard let titleLabel = titleLabel, titleLabel.text != .none else { return .zero }
		let additionalWidth = UIAccessibility.isBoldTextEnabled ? 1.5 : 0
		let additionalSize = CGSize(width: additionalWidth, height: 0)
		return titleLabel.intrinsicContentSize + additionalSize
	}
    
    /// 图片位置
    private var imagePlacement: UITextLayoutDirection {
        get {
            associated(Int.self, self, Associated.imagePlacement).flatMap(UITextLayoutDirection.init, fallback: .left)
        }
        set {
            setAssociatedObject(self, Associated.imagePlacement, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
            setupImageTitleEdgeInsets()
        }
    }
    
    /// Image-Title间距(大于等于0; 最好是偶数,否则按钮显示可能会有小小误差<iOS中像素对齐导致的问题>)
    private var imagePadding: CGFloat {
        get {
            associated(CGFloat.self, self, Associated.imagePadding).or(0.0)
        }
        set {
            assert(newValue >= 0, "A sane person would never do that.")
            setAssociatedObject(self, Associated.imagePadding, newValue, .OBJC_ASSOCIATION_ASSIGN)
            setupImageTitleEdgeInsets()
        }
    }
	
	private func setupImageTitleEdgeInsets() {
		guard imageSize != .zero && titleSize != .zero else { return }
		
		var imageInsets = UIEdgeInsets.zero
		var titleInsets = UIEdgeInsets.zero
		let halfPadding = imagePadding / 2.0
		
		/// 根据ContentVerticalAlignment和ContentHorizontalAlignment
		/// 以及ImagePlacement确定最终的Image/Title的EdgeInsets
		/// - 说明:
		///  - 平时使用最多的就是水平和垂直方向都居中的情况了,其他情况只为了加深印象
		var alignments = (contentVerticalAlignment, contentHorizontalAlignment)
		if #available(iOS 11, *) {
			alignments = (contentVerticalAlignment, effectiveContentHorizontalAlignment)
		}
		let titleHeightWithPadding = titleHeight + imagePadding
		let titleWidthWithPadding = titleWidth + imagePadding
		let imageHeightWithPadding = imageHeight + imagePadding
		let imageWidthWithPadding = imageWidth + imagePadding
		
		/// 垂直方向偏移
		let vOffset = abs(imageHeight - titleHeight) / 2.0
		/// 水平方向偏移
		let hOffset = abs(imageWidth - titleWidth) / 2.0
		/// 根据图片和标题的宽高决定其偏移距离
		var imageHOffset: CGFloat { titleWidth > imageWidth ? hOffset : 0 }
		var imageVOffset: CGFloat { titleHeight > imageHeight ? vOffset : 0 }
		var titleHOffset: CGFloat { imageWidth > titleWidth ? hOffset : 0 }
		var titleVOffset: CGFloat { imageHeight > titleHeight ? vOffset : 0 }
		
		switch alignments {
			
		case (.center, .center):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: -titleHeightWithPadding, left: 0, bottom: 0, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -imageHeightWithPadding, right: 0)
			case .left:
				imageInsets = UIEdgeInsets(top: 0, left: -halfPadding, bottom: 0, right: halfPadding)
				titleInsets = UIEdgeInsets(top: 0, left: halfPadding, bottom: 0, right: -halfPadding)
			case .down:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -titleHeightWithPadding, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: -imageHeightWithPadding, left: -imageWidth, bottom: 0, right: 0)
			case .right:
				let imageOffset = titleWidth + halfPadding
				let titleOffset = imageWidth + halfPadding
				imageInsets = UIEdgeInsets(top: 0, left: imageOffset, bottom: 0, right: -imageOffset)
				titleInsets = UIEdgeInsets(top: 0, left: -titleOffset, bottom: 0, right: titleOffset)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.center, .left):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: -titleHeightWithPadding, left: imageHOffset, bottom: 0, right: 0)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth + titleHOffset, bottom: -imageHeightWithPadding, right: -titleHOffset)
			case .left:
				titleInsets = UIEdgeInsets(top: 0, left: imagePadding, bottom: 0, right: -imagePadding)
			case .down:
				imageInsets = UIEdgeInsets(top: 0, left: imageHOffset, bottom: -titleHeightWithPadding, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: -imageHeightWithPadding, left: -imageWidth + titleHOffset, bottom: 0, right: 0)
			case .right:
				imageInsets = UIEdgeInsets(top: 0, left: titleWidthWithPadding, bottom: 0, right: -titleWidthWithPadding)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: imageWidth)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.center, .right):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: -titleHeightWithPadding, left: 0, bottom: 0, right: -titleWidth + imageHOffset)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -imageHeightWithPadding, right: titleHOffset)
			case .left:
				imageInsets = UIEdgeInsets(top: 0, left: -imagePadding, bottom: 0, right: imagePadding)
			case .down:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -titleHeightWithPadding, right: -titleWidth + imageHOffset)
				titleInsets = UIEdgeInsets(top: -imageHeightWithPadding, left: -imageWidth, bottom: 0, right: titleHOffset)
			case .right:
				imageInsets = UIEdgeInsets(top: 0, left: titleWidth, bottom: 0, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidthWithPadding, bottom: 0, right: imageWidthWithPadding)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.top, .left):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: 0, left: imageHOffset, bottom: 0, right: 0)
				titleInsets = UIEdgeInsets(top: imageHeightWithPadding, left: -imageWidth + titleHOffset, bottom: 0, right: 0)
			case .left:
				imageInsets = UIEdgeInsets(top: imageVOffset, left: 0, bottom: 0, right: 0)
				titleInsets = UIEdgeInsets(top: titleVOffset, left: imagePadding, bottom: 0, right: -imagePadding)
			case .down:
				imageInsets = UIEdgeInsets(top: titleHeightWithPadding, left: imageHOffset, bottom: -titleHeightWithPadding, right: 0)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth + titleHOffset, bottom: 0, right: 0)
			case .right:
				imageInsets = UIEdgeInsets(top: imageVOffset, left: titleWidthWithPadding, bottom: 0, right: -titleWidthWithPadding)
				titleInsets = UIEdgeInsets(top: titleVOffset, left: -imageWidth, bottom: 0, right: 0)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.top, .center):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: imageHeightWithPadding, left: -imageWidth, bottom: 0, right: 0)
			case .left:
				imageInsets = UIEdgeInsets(top: imageVOffset, left: -halfPadding, bottom: 0, right: halfPadding)
				titleInsets = UIEdgeInsets(top: titleVOffset, left: halfPadding, bottom: 0, right: -halfPadding)
			case .down:
				imageInsets = UIEdgeInsets(top: titleHeightWithPadding, left: 0, bottom: -titleHeightWithPadding, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: 0)
			case .right:
				let imageOffset = titleWidth + halfPadding
				let titleOffset = imageWidth + halfPadding
				imageInsets = UIEdgeInsets(top: imageVOffset, left: imageOffset, bottom: 0, right: -imageOffset)
				titleInsets = UIEdgeInsets(top: titleVOffset, left: -titleOffset, bottom: 0, right: titleOffset)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.top, .right):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleWidth + imageHOffset)
				titleInsets = UIEdgeInsets(top: imageHeightWithPadding, left: -imageWidthWithPadding, bottom: 0, right: titleHOffset)
			case .left:
				imageInsets = UIEdgeInsets(top: imageVOffset, left: -imagePadding, bottom: 0, right: imagePadding)
				titleInsets = UIEdgeInsets(top: titleVOffset, left: 0, bottom: 0, right: 0)
			case .down:
				imageInsets = UIEdgeInsets(top: titleHeightWithPadding, left: 0, bottom: -titleHeightWithPadding, right: -titleWidth + imageHOffset)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: titleHOffset)
			case .right:
				imageInsets = UIEdgeInsets(top: imageVOffset, left: titleWidth, bottom: 0, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: titleVOffset, left: -imageWidthWithPadding, bottom: 0, right: imageWidthWithPadding)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.bottom, .left):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: -titleHeightWithPadding, left: imageHOffset, bottom: titleHeightWithPadding, right: 0)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth + titleHOffset, bottom: 0, right: 0)
			case .left:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: imageVOffset, right: 0)
				titleInsets = UIEdgeInsets(top: 0, left: imagePadding, bottom: titleVOffset, right: -imagePadding)
			case .down:
				imageInsets = UIEdgeInsets(top: 0, left: imageHOffset, bottom: 0, right: 0)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth + titleHOffset, bottom: imageHeightWithPadding, right: 0)
			case .right:
				imageInsets = UIEdgeInsets(top: 0, left: titleWidthWithPadding, bottom: imageVOffset, right: -titleWidthWithPadding)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: titleVOffset, right: imageWidth)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.bottom, .center):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: titleHeightWithPadding, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: imageHeightWithPadding, left: -imageWidth, bottom: 0, right: 0)
			case .left:
				imageInsets = UIEdgeInsets(top: 0, left: -halfPadding, bottom: imageVOffset, right: halfPadding)
				titleInsets = UIEdgeInsets(top: 0, left: halfPadding, bottom: titleVOffset, right: -halfPadding)
			case .down:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: imageHeightWithPadding, right: 0)
			case .right:
				let imageOffset = titleWidth + halfPadding
				let titleOffset = imageWidth + halfPadding
				imageInsets = UIEdgeInsets(top: 0, left: imageOffset, bottom: imageVOffset, right: -imageOffset)
				titleInsets = UIEdgeInsets(top: 0, left: -titleOffset, bottom: titleVOffset, right: titleOffset)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		case (.bottom, .right):
			switch imagePlacement {
			case .up:
				imageInsets = UIEdgeInsets(top: -titleHeightWithPadding, left: 0, bottom: titleHeightWithPadding, right: -titleWidth + imageHOffset)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: titleHOffset)
			case .left:
				imageInsets = UIEdgeInsets(top: 0, left: -imagePadding, bottom: imageVOffset, right: imagePadding)
				titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: titleVOffset, right: 0)
			case .down:
				imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleWidth + imageHOffset)
				titleInsets = UIEdgeInsets(top: -imageHeightWithPadding, left: -imageWidth, bottom: imageHeightWithPadding, right: titleHOffset)
			case .right:
				imageInsets = UIEdgeInsets(top: 0, left: titleWidth, bottom: imageVOffset, right: -titleWidth)
				titleInsets = UIEdgeInsets(top: 0, left: -imageWidthWithPadding, bottom: titleVOffset, right: imageWidthWithPadding)
            @unknown default:
                fatalError("UNKOWN CASE")
            }
		default:
			break
		}
		imageEdgeInsets = imageInsets
		titleEdgeInsets = titleInsets
	}
    
    /// 给contentEdgeInsets写个别名, 避免讨厌的警告
    var contentInsets: UIEdgeInsets {
        get { contentEdgeInsets }
        set { contentEdgeInsets = newValue }
    }
}
