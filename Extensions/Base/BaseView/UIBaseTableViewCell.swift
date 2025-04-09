//
//  UIBaseTableViewCell.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/7/19.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

/// 背景样式设置模式
enum UIBackgroundStyleMode {
    /// 传统的样式设置背景色
    case legacy
    /// 使用iOS14的Configuration设置背景色
    case modern
}

class UIBaseTableViewCell: UITableViewCell, StandardLayoutLifeCycle {
    /// 分割线类
    fileprivate final class _UIBaseTableViewCellSeparatorView: UIView {}
    
    /// 缩进之后的边距
    private var indentedContentInsets: UIEdgeInsets {
        contentInsets.leftInset(indentationOffset)
    }
    
    /// 内容边距
    var contentInsets: UIEdgeInsets { .zero }
    
    /// 背景色
    var defaultBackgroundColor: UIColor? = defaultTableViewCellBackgroundColor {
        willSet {
            if #unavailable(iOS 14.0) {
                contentView.backgroundColor = newValue
            }
        }
        didSet {
            if #available(iOS 14.0, *) {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    /// 高亮时的背景色
    var defaultHighlightBackgroundColor: UIColor? = defaultTableViewCellHighlightBackgroundColor {
        didSet {
            if #available(iOS 14.0, *) {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    /// 选中时的背景色
    var defaultSelectedBackgroundColor: UIColor? = defaultTableViewCellSelectedBackgroundColor {
        didSet {
            if #available(iOS 14.0, *) {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    /// 是否在高亮状态自动显示/隐藏分割线
    var adjustSeparatorWhenHighlighted: Bool {
        false
    }
    
    /// 选中样式
    var defaultSelectionStyle: UITableViewCell.SelectionStyle { .default }
    
    /// 分割线
    fileprivate lazy var separator = _UIBaseTableViewCellSeparatorView(frame: .zero)
    
    /// 分割线像素高度 | 子类重写此属性并返回nil则不显示自定义的分割线
    var separatorPixelHeight: Int? { 1 }
    
    /// 为了方便静态表格视图中,给某一类Cell直接设置分割线的显示隐藏
    var showSeparator = true
    
    /// 圆角
    var preferredCornerRadius: CGFloat? { nil }
    
    /// 分组圆角的位置
    var sectionMaskedCorners = UIRectCorner.allCorners
    
    /// 分割线样式
    var separatorStyle = SeparatorStyle.inline
    
    /// 背景样式设置模式
    var backgroundStyleMode = UIBackgroundStyleMode.modern {
        didSet {
            if #available(iOS 14.0, *) {
                setNeedsUpdateConfiguration()
            }
            if backgroundStyleMode == .legacy {
                setHighlighted(isHighlighted, animated: false)
                setSelected(isSelected, animated: false)
            }
        }
    }
    
    /// 分配的IndexPath
    @Published var indexPath: IndexPath?
    
    @available(iOS 14.0, *)
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        var background = UIBackgroundConfiguration.listPlainCell()
        if backgroundStyleMode == .legacy {
            background = .clear()
        } else {
            /// 如果高亮或选中状态的颜色为空, 则使用tintColor作为默认颜色填充
            if let defaultHighlightBackgroundColor, state.isHighlighted {
                background.backgroundColor = defaultHighlightBackgroundColor
            } else if let defaultSelectedBackgroundColor, state.isSelected {
                background.backgroundColor = defaultSelectedBackgroundColor
            } else {
                if let defaultBackgroundColor {
                    background.backgroundColor = defaultBackgroundColor
                } else {
                    background = .clear()
                }
            }
        }
        
        backgroundConfiguration = background
        
        /// 设置分割线显示隐藏
        if adjustSeparatorWhenHighlighted {
            separator.isHidden = state.isHighlighted
            switch separatorStyle {
            case .regular(position: .bottom):
                if let teammateCellAbove {
                    teammateCellAbove.separator.isHidden = state.isHighlighted
                }
            case .inline, .regular(position: .top):
                if let teammateCellBelow {
                    teammateCellBelow.separator.isHidden = state.isHighlighted
                }
            }
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        /// 如果是iOS 14.0以下的系统, 则对contentView直接设置颜色
        if #unavailable(iOS 14.0) {
            contentView.backgroundColor = highlighted ? defaultHighlightBackgroundColor : defaultBackgroundColor
        } else {
            /// 如果是iOS 14.0以上的系统, 则只有背景样式为.legacy的时候才直接对contentView设置背景色
            if backgroundStyleMode == .legacy {
                contentView.backgroundColor = highlighted ? defaultHighlightBackgroundColor : defaultBackgroundColor
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        /// 如果是iOS 14.0以下的系统, 则对contentView直接设置颜色
        if #unavailable(iOS 14.0) {
            contentView.backgroundColor = selected ? defaultSelectedBackgroundColor : defaultBackgroundColor
        } else {
            /// 如果是iOS 14.0以上的系统, 则只有背景样式为.legacy的时候才直接对contentView设置背景色
            if backgroundStyleMode == .legacy {
                contentView.backgroundColor = selected ? defaultSelectedBackgroundColor : defaultBackgroundColor
            }
        }
    }
    
    func prepare() {
        /// 默认的选中样式
        selectionStyle = defaultSelectionStyle
        prepareSubviews()
        prepareConstraints()
    }
    
    func prepareSubviews() {
        if separatorPixelHeight.isValid {
            contentView.addSubview(separator)
        }
    }
    
    func prepareConstraints() {}
    
    private var indentationOffset: CGFloat {
        CGFloat(indentationLevel) * indentationWidth
    }
    
    /// 复写frame属性
    override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue.inset(by: indentedContentInsets)
            
            /// 这里正是处于 UITableViewDataSource 的 tableView(_:cellForRowAt:)的生命周期中
            if let tableView, let indexPath = tableView.indexPath(for: self) {
                
                /// 设置分割线
                if let separatorPixelHeight, showSeparator {
                    /// 根据缩进布局分割线
                    var separatorInsets: UIEdgeInsets {
                        let position: SeparatorPosition = separatorStyle == .regular(position: .bottom) ? .bottom : .top
                        let separatorVerticalOffset = bounds.height - separatorPixelHeight.cgFloat / UIScreen.main.scale
                        let insets = UIEdgeInsets(
                            top: position == .bottom ? separatorVerticalOffset : 0,
                            left: separatorInset.left + indentationOffset,
                            bottom: position == .top ? separatorVerticalOffset : 0,
                            right: separatorInset.right
                        )
                        return insets
                    }
                    /// 从TableView设置分割线颜色
                    separator.backgroundColor = tableView.separatorColor
                    /// 设置分割线位置
                    separator.frame = bounds.inset(by: separatorInsets)
                    
                    /// 如果发现系统的分割线则隐藏它
                    /// 注: 第一次进入Table的时候,有的Cell会出现系统分割线
                    /// 更新注↑: 在TableView初始化的时候就要设置separatorStyle = .none
                    /// 否则下面的方法里再设置分割线样式就会出现上面的情况
                    /// (lldb) po subviews
                    /// ▿ 3 elements
                    ///   - 0 : <_UISystemBackgroundView>
                    ///   - 1 : <UITableViewCellContentView>
                    ///   - 2 : <_UITableViewCellSeparatorView>
                    ///   系统分隔线常出现子视图数组的最后一个元素 | 这里做反转处理: Complexity: O(1)
                    /// let maybeSystemSeparator = subviews.reversed()
                    ///     .first { subview in
                    ///         subview.className == "_UITableViewCellSeparatorView"
                    ///     }
                    /// if let maybeSystemSeparator {
                    ///     maybeSystemSeparator.isHidden = true
                    /// }
                    
                    /// 调整分割线显示/隐藏
                    adjustSeparatorFor(tableView, at: indexPath)
                } else {
                    separator.isHidden = true
                }
                
                /// 设置圆角
                if let preferredCornerRadius {
                    setCornerRadius(preferredCornerRadius, for: tableView, at: indexPath)
                }
            }
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority) + indentedContentInsets
    }
    
    /// 实现Cell直接加分割线的效果
    /// - Parameters:
    ///   - tableView: Cell容器TableView
    ///   - indexPath: 所在的indexPath
    func adjustSeparatorFor(_ tableView: UITableView, at indexPath: IndexPath) {
        /// 在TableView初始化的时候就要设置separatorStyle = .none
        /// 第一次进入TableViewController时获取的sectionHeight不正常 所以这里做延迟1ms处理
        DispatchQueue.main.asyncAfter(deadline: indexPath.section + indexPath.row == 0 ? 0.001 : 0.0) {
            /// HeaderHeight + CellsHeight + FooterHeight
            let sectionHeight = tableView.rect(forSection: indexPath.section).height
            /// Section Header's frame
            let sectionHeaderRect = tableView.rectForHeader(inSection: indexPath.section)
            /// Section Footer's frame
            let sectionFooterRect = tableView.rectForFooter(inSection: indexPath.section)
            /// Cells Height
            let sectionCellsHeight = sectionHeight - sectionHeaderRect.height - sectionFooterRect.height
            if case .regular = self.separatorStyle {
                self.separator.isHidden = false
            } else {
                if sectionCellsHeight > self.frame.height {
                    self.separator.isHidden = indexPath.row == 0
                } else {
                    /// 分组内只有一行的情况
                    self.separator.isHidden = self.frame.maxY == sectionFooterRect.minY
                }
            }
        }
    }
    
    /// 实现分组样式时,第一行和最后一行分别加圆角
    /// 调用时机:tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    /// - Parameters:
    ///   - tableView: Cell容器TableView
    ///   - indexPath: 所在的indexPath
    /// - Returns: Cell本身
    func setCornerRadius(_ cornerRadius: CGFloat, for tableView: UITableView, at indexPath: IndexPath) {
        lazy var haveHeader: Bool = {
            guard let tableDelegate = tableView.delegate else { return false }
            let headerHeight = tableDelegate.tableView?(tableView, heightForHeaderInSection: indexPath.section) ?? 0.0
            let headerView = tableDelegate.tableView?(tableView, viewForHeaderInSection: indexPath.section)
            return headerHeight != 0.0 && headerView.isValid
        }()
        lazy var haveFooter: Bool = {
            guard let tableDelegate = tableView.delegate else { return false }
            let footerHeight = tableDelegate.tableView?(tableView, heightForFooterInSection: indexPath.section) ?? 0.0
            let footerView = tableDelegate.tableView?(tableView, viewForFooterInSection: indexPath.section)
            return footerHeight != 0.0 && footerView.isValid
        }()
        /// 分组内只有1行的情况
        if indexPath.row == 0, tableView.numberOfRows(inSection: indexPath.section) == 1 {
            var corners: UIRectCorner {
                var result = sectionMaskedCorners
                if haveHeader {
                    /// 减去顶部的圆角
                    result.subtract(.topCorners)
                }
                if haveFooter {
                    /// 减去底部的圆角
                    result.subtract(.bottomCorners)
                }
                return result
            }
            contentView.roundCorners(corners: corners, cornerRadius: cornerRadius)
        }
        /// 第一行
        else if indexPath.row == 0 {
            /// 有组头
            if haveHeader {
                contentView.roundCorners(corners: .allCorners, cornerRadius: 0.0)
            }
            /// 无组头
            else {
                contentView.roundCorners(corners: sectionMaskedCorners.topCorners, cornerRadius: cornerRadius)
            }
        }
        /// 最后一行
        else if tableView.numberOfRows(inSection: indexPath.section) == indexPath.row + 1 {
            /// 有组尾
            if haveFooter {
                contentView.roundCorners(corners: .allCorners, cornerRadius: 0)
            }
            /// 无组尾
            else {
                contentView.roundCorners(corners: sectionMaskedCorners.bottomCorners, cornerRadius: cornerRadius)
            }
        }
        /// 中间行
        else {
            contentView.roundCorners(corners: .allCorners, cornerRadius: 0.0)
        }
    }
}

extension UIBaseTableViewCell {
    
    enum SeparatorPosition: Equatable {
        case top
        case bottom
    }
    
    enum SeparatorStyle: Equatable {
        /// 总是显示Cell分割线(可设置分割线显示的位置在顶部或在底部)
        case regular(position: SeparatorPosition)
        /// 只显示分组内的分割线(隐藏组尾Cell的分割线)
        case inline
    }
}

extension UIBaseTableViewCell {
    
    /// 同组的下面的Cell
    var teammateCellBelow: UIBaseTableViewCell? {
        guard let maybeIndexPath else { return nil }
        guard let neighborCellBelow else { return nil }
        guard let neighborIndexPath = neighborCellBelow.maybeIndexPath else { return nil }
        guard maybeIndexPath.section == neighborIndexPath.section else { return nil }
        return neighborCellBelow
    }
    
    /// 同组的上面的Cell
    var teammateCellAbove: UIBaseTableViewCell? {
        guard let maybeIndexPath else { return nil }
        guard let neighborCellAbove else { return nil }
        guard let neighborIndexPath = neighborCellAbove.maybeIndexPath else { return nil }
        guard maybeIndexPath.section == neighborIndexPath.section else { return nil }
        return neighborCellAbove
    }
    
    /// 可见的邻居(本Cell下面的)Cell(可能是不同分组的Cell)
    var neighborCellBelow: UIBaseTableViewCell? {
        guard let tableView else { return nil }
        /// 取得可见Cell数组
        let visibleCells = tableView.visibleCells
        /// 确保找到自己在数组中的位置并保证数组下标安全
        guard let myIndex = visibleCells.firstIndex(of: self), myIndex + 1 <= visibleCells.endIndex else { return nil }
        /// 得出下一个可见Cell的下标
        let nextIndex = visibleCells.index(myIndex, offsetBy: 1)
        /// 类型转换并返回
        return visibleCells.element(at: nextIndex) as? UIBaseTableViewCell
    }
    
    /// 可见的邻居(本Cell上面的)Cell(可能是不同分组的Cell)
    var neighborCellAbove: UIBaseTableViewCell? {
        guard let tableView else { return nil }
        /// 取得可见Cell数组
        let visibleCells = tableView.visibleCells
        /// 确保找到自己在数组中的位置并保证数组下标安全
        guard let myIndex = visibleCells.firstIndex(of: self), myIndex - 1 >= visibleCells.startIndex else { return nil }
        /// 得出上一个可见Cell的下标
        let lastIndex = visibleCells.index(myIndex, offsetBy: -1)
        /// 类型转换并返回
        return visibleCells.element(at: lastIndex) as? UIBaseTableViewCell
    }
    
    /// 按indexPath -> inferredIndexPath获取IndexPath
    var maybeIndexPath: IndexPath? {
        indexPath ?? inferredIndexPath
    }
}
