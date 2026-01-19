//
//  UIBaseTableViewHeaderFooterView.swift
//
//  Created by Choi on 2022/8/23.
//

import UIKit

class UIBaseTableViewHeaderFooterView: UITableViewHeaderFooterView, UIViewLifeCycle {
    
    /// 内容边距
    var contentInsets: UIEdgeInsets { .zero }
    
    /// 背景色
    var defaultBackgroundColor: UIColor? {
        .baseBackground
    }
    
    /// 圆角
    var preferredCornerRadius: CGFloat? { nil }
    
    /// 分配的分组
    @Published var section: Int?
    
    /// 背景样式设置模式
    var backgroundStyleMode: UIBackgroundStyleMode = .modern {
        didSet {
            setNeedsUpdateConfiguration()
            if backgroundStyleMode == .legacy {
                contentView.backgroundColor = defaultBackgroundColor
            }
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    override func updateConfiguration(using state: UIViewConfigurationState) {
        super.updateConfiguration(using: state)
        var background: UIBackgroundConfiguration
        if backgroundStyleMode == .legacy {
            background = .clear()
        } else {
            background = UIBackgroundConfiguration.listPlainHeaderFooter()
            background.backgroundColor = defaultBackgroundColor
        }
        /**
         一种新的设置颜色的方法
         */
//        background.backgroundColorTransformer = UIConfigurationColorTransformer { color in
//            color.withAlphaComponent(0.3)
//        }
        backgroundConfiguration = background
    }
    
    // 复写frame属性
    override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue.inset(by: contentInsets)
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority) + contentInsets
    }
    
    func prepare() {
        contentView.backgroundColor = defaultBackgroundColor
        prepareSubviews()
        prepareConstraints()
    }
    
    func prepareSubviews() {}
    
    func prepareConstraints() {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let preferredCornerRadius, let tableView, let section {
            let headerRect = tableView.rectForHeader(inSection: section)
            let footerRect = tableView.rectForFooter(inSection: section)
            let haveRows = headerRect.maxY != footerRect.minY
            let isHeaderView = headerRect != .zero && headerRect == frame
            let maskedCorners = maskedCorners(isHeaderView, haveRows: haveRows)
            addCornerRadius(preferredCornerRadius, corners: maskedCorners)
        }
    }
    
    /// 圆角位置
    /// - Parameters:
    ///   - isHeader: 是否给组头加圆角
    ///   - haveRows: 行数是否非空
    /// - Returns: 要切的圆角位置
    func maskedCorners(_ isHeader: Bool, haveRows: Bool) -> UIRectCorner {
        switch (isHeader, haveRows) {
        case (true, true): /// 组头,行不为空
            return .topCorners
        case (false, true): /// 组尾,行不为空
            return .bottomCorners
        default:
            return .allCorners
        }
    }
}

extension UIBaseTableViewHeaderFooterView {
    
    /// 计算得出的indexPath
    /// 但是在组内的cell为0的时候无效, 需要配合assignedSection使用
    private var indexPath: IndexPath? {
        let sectionFirstRowMinOrigin = CGPoint(x: 0.0, y: frame.maxY)
        return tableView?.indexPathForRow(at: sectionFirstRowMinOrigin)
    }
}
