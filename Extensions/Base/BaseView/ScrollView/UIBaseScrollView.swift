//
//  UIBaseScrollView.swift
//
//  Created by Choi on 2022/8/15.
//

import UIKit
import Combine

class UIBaseScrollView: UIScrollView, UIViewLifeCycle {
    
    class var scrollDirection: NSLayoutConstraint.Axis {
        NSLayoutConstraint.Axis.vertical
    }
    
    var defaultBackgroundColor: UIColor? = .baseBackground {
        willSet {
            backgroundColor = newValue
            contentView.backgroundColor = newValue
        }
    }
    
    /// 滚动方向
    private(set) lazy var scrollDirection = Self.scrollDirection
    
    /// 内容视图
    lazy var contentView = makeContentView()
    
    private var observingContentSize: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    func prepare() {
        prepareSubviews()
        prepareConstraints()
        /// 内容边距自动调整
        contentInsetAdjustmentBehavior = .automatic
        /// 交互时收起键盘
        keyboardDismissMode = .interactive
        /// 背景色
        backgroundColor = defaultBackgroundColor
        /// 垂直滚动条隐藏
        showsVerticalScrollIndicator = false
        /// 水平滚动条隐藏
        showsHorizontalScrollIndicator = false
    }
    
    func prepareSubviews() {
        addSubview(contentView)
    }
    
    override func updateConstraints() {
        contentView.snp.remakeConstraints { make in
            make.edges.equalTo(contentLayoutGuide)
        }
        contentLayoutGuide.snp.remakeConstraints { make in
            switch scrollDirection {
            case .horizontal:
                make.height.equalTo(frameLayoutGuide)
            case .vertical:
                make.width.equalTo(frameLayoutGuide)
            @unknown default:
                fatalError("Unhandled condition")
            }
        }
        super.updateConstraints()
    }
    
    func prepareConstraints() { }
    
    func makeContentView() -> UIView {
        UIView(color: defaultBackgroundColor)
    }
    
    /// 设置自身尺寸根据ContentView自动调整
    /// 注: 不能默认就观察ContentView的尺寸变化, 需要根据条件启用这一特性. 因为有的子类会用到ContentView的method swizzling, 这会和KVO有冲突
    func setAutoResize(_ autoResize: Bool) {
        if autoResize {
            /// 移除重复项, 避免滚动时持续发送事件
            observingContentSize = contentView.publisher(for: \.bounds, options: .live).removeDuplicates().sink {
                [unowned self] _ in
                invalidateIntrinsicContentSize()
            }
        } else {
            observingContentSize?.cancel()
            observingContentSize = nil
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        observingContentSize.isValid ? contentView.bounds.size : super.intrinsicContentSize
    }
}

typealias UIBaseVerticalScrollView = UIBaseScrollView

class UIBaseHorizontalScrollView: UIBaseScrollView {
    
    override class var scrollDirection: NSLayoutConstraint.Axis {
        NSLayoutConstraint.Axis.horizontal
    }
}
