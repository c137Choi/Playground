//
//  UIStackViewPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2020/10/10.
//  Copyright © 2020 Choi. All rights reserved.
//

import UIKit

extension UIStackView {
    
    convenience init(arrangedSubviews: UIView...) {
        self.init(arrangedSubviews: arrangedSubviews)
    }
    
    convenience init(
        insets: UIEdgeInsets? = nil,
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .leading,
        spacing: CGFloat = 0.0,
        @ArrayBuilder<UIView> arrangedSubviews: () -> [UIView] = { [] })
    {
        self.init(insets: insets,
                  axis: axis,
                  distribution: distribution,
                  alignment: alignment,
                  spacing: spacing,
                  arrangedSubviews: arrangedSubviews())
    }
    
    convenience init(
        insets: UIEdgeInsets? = nil,
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .leading,
        spacing: CGFloat = 0.0,
        arrangedSubviews: UIView...)
    {
        self.init(insets: insets,
                  axis: axis,
                  distribution: distribution,
                  alignment: alignment,
                  spacing: spacing,
                  arrangedSubviews: arrangedSubviews)
    }
    
    convenience init(
        insets: UIEdgeInsets? = nil,
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .leading,
        spacing: CGFloat = 0.0,
        arrangedSubviews: [UIView])
    {
        self.init(arrangedSubviews: arrangedSubviews)
        self.contentInsets = insets
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        self.arrangedSubviews.forEach { subview in
            guard let afterSpacing = subview.afterSpacing else { return }
            setCustomSpacing(afterSpacing, after: subview)
        }
    }
    
    func addArrangedSubview(_ view: UIView, afterSpacing: CGFloat) {
        addArrangedSubview(view)
        setCustomSpacing(afterSpacing, after: view)
    }
    
    func insertArrangedSubview(_ view: UIView, at stackIndex: Int, afterSpacing: CGFloat) {
        insertArrangedSubview(view, at: stackIndex)
        setCustomSpacing(afterSpacing, after: view)
    }
    
    func reArrange(@ArrayBuilder<UIView> _ arrangedSubviews: () -> [UIView]) {
        reArrange(arrangedSubviews())
    }
    
    func arrange(@ArrayBuilder<UIView> arrangedSubviews: () -> [UIView]) {
        arrange(arrangedSubviews: arrangedSubviews())
    }
    
    func reArrange<T>(_ arrangedSubviews: T...) where T: UIView {
        reArrange(arrangedSubviews)
    }
    
    func reArrange<T>(_ arrangedSubviews: T) where T: Sequence, T.Element: UIView {
        clearArrangedSubviews()
        arrange(arrangedSubviews: arrangedSubviews)
    }
    
    func arrange<T>(arrangedSubviews: T) where T: Sequence, T.Element: UIView {
        arrangedSubviews.forEach { subview in
            addArrangedSubview(subview)
            /// Tip: 如果后面还有别的arrangedSubview的时候，customSpacing才有效
            /// 如果后面没有别的arrangedSubview则最后一个子视图后面使用contentInsets作为内边距
            /// 注1: 设置后间距为 UIStackView.spacingUseDefault 可以取消之前设置的自定义后间距, 恢复默认的spacing间距
            /// 注2: (不常用)初始化UIStackView的时候设置 spacing 为UIStackView.spacingUseSystem会给UIStackView一个默认 8pt 的 spacing
            setCustomSpacing(subview.afterSpacing ?? UIStackView.spacingUseDefault, after: subview)
        }
    }
    
    /// 清除所有的arrangedSubview
    func clearArrangedSubviews() {
        arrangedSubviews.forEach(clearArrangedSubview)
    }
    
    /// 清除StackView中指定的arrangedSubview
    func clearArrangedSubview(_ arrangedSubview: UIView) {
        removeArrangedSubview(arrangedSubview)
        arrangedSubview.removeFromSuperview()
    }
    
    /// 设置背景色
    func setBackgroundColor(_ backgroundColor: UIColor?,
                            cornerRadius: CGFloat? = nil,
                            maskedCorners: CACornerMask = .allCorners,
                            borderWidth: CGFloat? = nil,
                            borderColor: UIColor? = nil)
    {
        /// iOS 14.0以后UIStackView的layer从CATransformLayer改成了CALayer
        /// 因此可以直接设置背景色
        if #available(iOS 14.0, *) {
            self.backgroundColor = backgroundColor
            self.layer.cornerRadius = cornerRadius.or(0)
            self.layer.maskedCorners = maskedCorners
            self.layer.borderColor = borderColor.map(\.cgColor)
            self.layer.borderWidth = borderWidth.or(0)
        } else {
            if let backgroundColor {
                insertBackgroundView(
                    color: backgroundColor,
                    cornerRadius: cornerRadius,
                    maskedCorners: maskedCorners,
                    borderWidth: borderWidth,
                    borderColor: borderColor
                )
            } else {
                kk.backgroundView = nil
            }
        }
    }
    
    var reArrangedSubviews: [UIView] {
        get { arrangedSubviews }
        set {
            reArrange(newValue)
        }
    }
    
    /// 内部控件边距
    var contentInsets: UIEdgeInsets? {
        get {
            if #available(iOS 11, *) {
                return directionalLayoutMargins.uiEdgeInsets
            } else {
                return layoutMargins
            }
        }
        set(insets) {
            isLayoutMarginsRelativeArrangement = insets.isValid
            guard let insets else { return }
            if #available(iOS 11, *) {
                directionalLayoutMargins = insets.directionalEdgeInsets
            } else {
                layoutMargins = insets
            }
        }
    }
    
    var horizontalInsets: UIEdgeInsets? {
        get { contentInsets }
        set(insets) {
            guard var insets else { return }
            insets.top = 0
            insets.bottom = 0
            contentInsets = insets
        }
    }
    
    var verticalInsets: UIEdgeInsets? {
        get { contentInsets }
        set(insets) {
            guard var insets else { return }
            insets.left = 0
            insets.right = 0
            contentInsets = insets
        }
    }
}
