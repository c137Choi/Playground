//
//  UIBaseScrollView.swift
//
//  Created by Choi on 2022/8/15.
//

import UIKit

class UIBaseScrollView: UIScrollView, StandardLayoutLifeCycle {
    
    class var scrollableAxis: NSLayoutConstraint.Axis {
        .vertical
    }
    
    /// 是否开启: 触摸到UIControl子类的时候阻断滚动视图的滚动
    /// 避免如像UISlider类似的控件在滑动时被UIScrollView滑动事件阻断的问题
    var blockScrollWhenHitUIControls = true {
        didSet {
            if blockScrollWhenHitUIControls == false {
                isScrollEnabled = true
            }
        }
    }
    
    var defaultBackgroundColor: UIColor? = baseViewBackgroundColor {
        willSet {
            backgroundColor = newValue
            contentView.backgroundColor = newValue
        }
    }
    
    private(set) lazy var scrollableAxis = Self.scrollableAxis
    
    lazy var contentView = makeContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    /// 避免如像UISlider类似的控件在滑动时被UIScrollView滑动事件阻断的问题
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let receiver = super.hitTest(point, with: event)
        if blockScrollWhenHitUIControls {
            /// UIControl或其子类
            let isKindOfControl = receiver.or(false) {
                $0.isKind(of: UIControl.self)
            }
            if isKindOfControl {
                isScrollEnabled = false
            } else {
                isScrollEnabled = true
            }
        }
        return receiver
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
        contentView.snp.remakeConstraints { content in
            content.edges.equalToSuperview()
            switch scrollableAxis {
            case .horizontal:
                content.height.equalToSuperview()
            case .vertical:
                content.width.equalToSuperview()
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
}

typealias UIBaseVerticalScrollView = UIBaseScrollView

class UIBaseHorizontalScrollView: UIBaseScrollView {
    override class var scrollableAxis: NSLayoutConstraint.Axis { .horizontal }
}
