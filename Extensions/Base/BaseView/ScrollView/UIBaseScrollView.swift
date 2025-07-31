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
    
    func prepare() {
        prepareSubviews()
        prepareConstraints()
        /// 标记: 不可取消内容点击, 使UIControl子视图可自由交互
        canCancelContentTouches = false
        /// 内容边距自动调整
        contentInsetAdjustmentBehavior = .automatic
        /// 交互时收起键盘
        keyboardDismissMode = .interactive
        /// 背景色
        backgroundColor = defaultBackgroundColor
        /// 隐藏滚动条
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    func prepareSubviews() {
        addSubview(contentView)
    }
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        /// 如果触摸点在UIControl上, 则优先处理UIControl事件
        if view is UIControl {
            return true
        } else {
            return super.touchesShouldBegin(touches, with: event, in: view)
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        /// 如果是UIControl, 不取消触摸事件
        if view is UIControl {
            return false
        } else {
            return super.touchesShouldCancel(in: view)
        }
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
