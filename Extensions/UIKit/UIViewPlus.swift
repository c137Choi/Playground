//
//  UIViewPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/14.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit
import SwiftUI

extension UIView {
	
	convenience init(color: UIColor?) {
		self.init(frame: .zero)
		backgroundColor = color
	}
}

// MARK: - __________ Getters __________
extension KK where Base: UIView {
    private typealias Associated = UIView.Associated
    
    /// 使用命名空间,避免和UICollectionView,UITableView的属性名冲突
    var backgroundView: UIView? {
        get {
            associated(UIView.self, base, UIView.Associated.backgroundView)
        }
        nonmutating set {
            /// 移除旧背景(如果存在)
            if let oldBackground = backgroundView {
                oldBackground.removeFromSuperview()
            }
            /// 保存新背景
            setAssociatedObject(base, UIView.Associated.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
extension UIView {
    /// 背景View
    final class _BackgroundView: UIView {}
    /// 阴影View
    final class _ShadowView: UIView {}
    /// 关联值
    enum Associated {
        @UniqueAddress static var afterSpacing
        @UniqueAddress static var shadowView
        @UniqueAddress static var backgroundView
        @UniqueAddress static var mournFilterView
        @UniqueAddress static var targets
        @UniqueAddress static var tappedClosure
    }
    
    var isVisibleAndPrepared: Bool {
        isVisible && isPrepared
    }
    
    /// 是否可见
    /// 注: 只简单判断几个条件: 未隐藏\window属性有效\透明度超过阈值. 更复杂的层级结构需要根据情况具体判断
    var isVisible: Bool {
        !isHidden && window.isValid && alpha >= 0.01
    }
    
    /// 是否透明
    var isTransparent: Bool {
        get { alpha == 0 }
        set { alpha = newValue ? 0 : 1 }
    }
    
    /// 返回在Window中的中心点
    var centerInWindow: CGPoint {
        convert(bounds.center, to: nil)
    }
    
    /// 返回在Window中的frame
    var frameInWindow: CGRect {
        convert(bounds, to: nil)
    }
    
    var naturalSize: CGSize {
        systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    var isPortrait: Bool {
        frame.size.isPortrait
    }
    
    var isLandscape: Bool {
        frame.size.isLandscape
    }
    
    var targets: NSMutableArray {
        if let array = associated(NSMutableArray.self, self, Associated.targets) {
            return array
        } else {
            let array = NSMutableArray()
            setAssociatedObject(self, Associated.targets, array, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return array
        }
    }
    
    /// 用于设置UIStackView.arrangedSubviews布局
    var afterSpacing: CGFloat? {
        get {
            associated(CGFloat.self, self, Associated.afterSpacing)
        }
        set {
            setAssociatedObject(self, Associated.afterSpacing, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var mournView: UIView? {
        get {
            associated(UIView.self, self, Associated.mournFilterView)
        }
        set {
            setAssociatedObject(self, Associated.mournFilterView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否变形: 宽高不等于固定尺寸的宽高
    public func isDeformed(axis: NSLayoutConstraint.Axis) -> Bool {
        isStretched(axis: axis) || isSqueezed(axis: axis)
    }
    
    /// 是否被挤压: 宽/高是否大于固定尺寸的宽/高
    public func isStretched(axis: NSLayoutConstraint.Axis) -> Bool {
        switch axis {
        case .horizontal:
            bounds.width > intrinsicContentSize.width
        case .vertical:
            bounds.height > intrinsicContentSize.height
        @unknown default:
            fatalError("Unhandled condition...")
        }
    }
    
    /// 是否被挤压: 宽/高是否小于固定尺寸的宽/高
    public func isSqueezed(axis: NSLayoutConstraint.Axis) -> Bool {
        switch axis {
        case .horizontal:
            bounds.width < intrinsicContentSize.width
        case .vertical:
            bounds.height < intrinsicContentSize.height
        @unknown default:
            fatalError("Unhandled condition...")
        }
    }
    
    /// 根据中心点计算目标Frame
    /// - Parameters:
    ///   - targetCenter: 目标中心点
    ///   - size: 目标Size | 如果为空则使用frame.size
    /// - Returns: 目标Frame
    public func targetFrame(targetCenter: CGPoint, size: CGSize? = nil) -> CGRect {
        let targetSize = size ?? frame.size
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height
        let x = targetCenter.x - targetWidth.half
        let y = targetCenter.y - targetHeight.half
        return CGRect(x: x, y: y, width: targetWidth, height: targetHeight)
    }
    
    /// 清空所有的约束
    public func removeAllConstraints() {
        removeConstraints(constraints)
    }
    
    /// Quick configuration to give the view shadows.
    public func addShadow(offset: CGSize = .zero, opacity: Float = 0.65, radius: CGFloat = 20, color: UIColor = .black) {
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.masksToBounds = false
    }
    
    /// 翻转
    /// - Parameter degree: 翻转读数: 一周为360°
    public func rotate(_ degree: Int) {
        let angle = (CGFloat.pi / 180.0) * degree.cgFloat
        transform = CGAffineTransform(rotationAngle: angle)
    }
    
    /// 计算自动布局下的尺寸
    /// - Parameters:
    ///   - maxSize: 限制最大尺寸
    ///   - stretchAxis: 拉伸的轴向
    /// - Returns: 需要的最小尺寸
    public func preferredSize(maxSize: CGSize? = nil, stretchAxis: NSLayoutConstraint.Axis = .vertical) -> CGSize {
        var systemLayoutSize = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if let maxSize {
            switch stretchAxis {
            case .horizontal:
                if systemLayoutSize.height > maxSize.height {
                    systemLayoutSize = systemLayoutSizeFitting(maxSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
                }
            case .vertical:
                if systemLayoutSize.width > maxSize.width {
                    systemLayoutSize = systemLayoutSizeFitting(maxSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                }
            @unknown default:
                break
            }
        }
        return systemLayoutSize
    }
    
    /// 哀悼(给视图加上黑白滤镜)
    @available(iOS 12.0, *)
    public func mourn(_ mourn: Bool = true) {
        if let mournView {
            if mourn {
                mournView.frame = bounds
            } else {
                mournView.removeFromSuperview()
                self.mournView = nil
            }
        } else if mourn {
            let mournFilter = UIView(frame: bounds)
            mournFilter.isUserInteractionEnabled = false
            mournFilter.backgroundColor = .lightGray
            mournFilter.layer.compositingFilter = "saturationBlendMode"
            mournFilter.layer.zPosition = .greatestFiniteMagnitude
            addSubview(mournFilter)
            self.mournView = mournFilter
        }
    }
    
    func relativeFrameTo(_ target: UIView) -> CGRect? {
        superview?.convert(frame, to: target)
    }
    
    func tagged(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }
    
    /// 添加背景色
    /// - Parameter backgroundColor: 背景颜色
    func addBackgroundColor(_ backgroundColor: UIColor) {
        let background = UIView(frame: bounds)
        background.backgroundColor = backgroundColor
        insertBackgroundView(background)
    }
    
    
    /// 添加背景
    func insertBackgroundView(
        color: UIColor,
        insets: UIEdgeInsets = .zero,
        cornerRadius: CGFloat?,
        maskedCorners: CACornerMask = .allCorners,
        borderWidth: CGFloat? = nil,
        borderColor: UIColor? = nil)
    {
        let background = _BackgroundView(color: color)
        background.layer.maskedCorners = maskedCorners
        background.layer.cornerRadius = cornerRadius.or(0)
        background.layer.borderColor = borderColor.map(\.cgColor)
        background.layer.borderWidth = borderWidth.or(0)
        insertBackgroundView(background, insets: insets)
    }
    
    /// 添加背景
    /// - Parameters:
    ///   - background: 背景子视图
    ///   - insets: 缩进边距
    ///   - configure: 其他设置
    func insertBackgroundView(_ background: UIView, insets: UIEdgeInsets = 0, configure: (UIView) -> Void = { _ in }) {
        /// 按Bounds缩进
        let frame = bounds.inset(by: insets)
        /// 其他配置
        configure(background)
        /// 添加背景图
        insertBackgroundView(background, frame: frame)
    }
    
    /// 添加背景子视图
    /// - Parameters:
    ///   - background: 背景子视图
    ///   - frame: 背景图位置
    func insertBackgroundView(_ background: UIView, frame: CGRect) {
        background.frame = frame
        background.autoresizingMask = .autoResize
        insertSubview(background, at: 0)
        kk.backgroundView = background
    }
    
	func snapshotScreen(scrollView: UIScrollView) -> UIImage?{
		if UIScreen.main.responds(to: #selector(getter: UIScreen.scale)) {
			UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, UIScreen.main.scale)
		} else {
			UIGraphicsBeginImageContext(scrollView.contentSize)
		}
		
		let savedContentOffset = scrollView.contentOffset
		let savedFrame = scrollView.frame
		let contentSize = scrollView.contentSize
		let oldBounds = scrollView.layer.bounds
		
		if #available(iOS 13, *) {
			//iOS 13 系统截屏需要改变tableview 的bounds
			scrollView.layer.bounds = CGRect(x: oldBounds.origin.x, y: oldBounds.origin.y, width: contentSize.width, height: contentSize.height)
		}
		//偏移量归零
		scrollView.contentOffset = CGPoint.zero
		//frame变为contentSize
		scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
		
		//截图
		if let context = UIGraphicsGetCurrentContext() {
			scrollView.layer.render(in: context)
		}
		if #available(iOS 13, *) {
			scrollView.layer.bounds = oldBounds
		}
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		//还原frame 和 偏移量
		scrollView.contentOffset = savedContentOffset
		scrollView.frame = savedFrame
		return image
	}
	
	private func getTableViewScreenshot(tableView: UITableView,whereView: UIView) -> UIImage?{
		// 创建一个scrollView
		let scrollView = UIScrollView()
		// 设置颜色
		scrollView.backgroundColor = UIColor.white
		// 设置位置
		scrollView.frame = whereView.bounds
		// 设置滚动位置
		scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: tableView.contentSize.height)
		// 将tableView加载到视图中
		scrollView.addSubview(tableView)
		// 设置位置
		let constraints = [
			tableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			tableView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			tableView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			tableView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
			tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height)
		]
		NSLayoutConstraint.activate(constraints)
		/// 添加到指定视图
		whereView.addSubview(scrollView)
		/// 截图
		let image = snapshotScreen(scrollView: scrollView)
		/// 移除scrollView
		scrollView.removeFromSuperview()
		return image
	}
    
    /// 截图指定区域
    func snapshot(frame: CGRect) -> UIImage? {
        guard let snapshot else { return nil }
        guard let cgImage = snapshot.cgImage else { return nil }
        let scale = UIScreen.main.scale
        let transform = CGAffineTransformMakeScale(scale, scale)
        let scaledRect = CGRectApplyAffineTransform(frame, transform)
        guard let scaledCGImage = cgImage.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: scaledCGImage)
    }
    
    /// 注1: 必须要有父视图或window非空的情况下才可以截图成功
    /// 注2: width或height有一个为空(或近似为0, 如:0.1), drawHierarchy就会crash
    /// https://stackoverflow.com/questions/21722508/ios-drawviewhierarchyinrect-crash-exc-breakpoint-unknown
	var snapshot: UIImage? {
        guard window.isValid else {
            assertionFailure("对不可见的视图截图会导致崩溃")
            return nil
        }
        switch self {
        case let unwrapped where unwrapped is UITableView:
            let tableView = unwrapped as! UITableView
            return getTableViewScreenshot(tableView: tableView, whereView: superview!)
        default:
            /// 屏幕scale
            let scale = UIScreen.main.scale
            /// 是否不透明
            let isOpaque = false
            /// 渲染图片
            if #available(iOS 10.0, *) {
                let format = UIGraphicsImageRendererFormat()
                format.scale = scale
                format.opaque = isOpaque
                /// 创建绘图渲染器
                let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
                /// 使用PNG图片格式
                let pngData = renderer.pngData { context in
                    drawHierarchy(in: bounds, afterScreenUpdates: true)
                }
                /// 或者使用JPEG图片
                let _ = renderer.jpegData(withCompressionQuality: 1.0) { context in
                    
                }
                return UIImage(data: pngData)
            } else {
                UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, scale)
                defer {
                    UIGraphicsEndImageContext()
                }
                guard drawHierarchy(in: bounds, afterScreenUpdates: true) else { return nil }
                return UIGraphicsGetImageFromCurrentImageContext()
            }
        }
	}
    
    /// 用于调整父视图为ScrollView子类时, 其子视图被自身遮挡的问题
    /// 通常赋值给控制器的.additionalSafeAreaInsets属性, 让ScrollView自动适配边距
    /// 注: 这时自身底部的约束就不好设置成相对父视图的safeAreaLayoutGuide了, 直接相对于父视图本身能达到效果.
    /// 可能不是最优解,待后续优化
    @available(iOS 11.0, *)
    var additionalSafeAreaInsetsFromSuperView: UIEdgeInsets {
        .bottom(bottomSafeAreaPadding + frame.height)
    }
    
    @available(iOS 11.0, *)
    var bottomSafeAreaPadding: Double {
        guard let superview else { return 0 }
        return superview.bounds.height - frame.maxY - superview.safeAreaInsets.bottom
    }
}

// MARK: - __________ Functions __________
extension Array where Element: UIView {
	
	/// 将UIView的数组包装的StackView里
	/// - Returns: The stack view wrapping the given view array as arranged subviews.
	func embedInStackView(
		axis: NSLayoutConstraint.Axis = .vertical,
		distribution: UIStackView.Distribution = .fill,
		alignment: UIStackView.Alignment = .leading,
		spacing: CGFloat = 0)
	-> UIStackView {
		let stackView = UIStackView(arrangedSubviews: self)
		stackView.axis = axis
		stackView.distribution = distribution
		stackView.alignment = alignment
		stackView.spacing = spacing
		return stackView
	}
}
extension UIView {
    
    /// 固定比例(宽/高)
    /// - Parameters:
    ///   - widthHeightRatio: 宽高比
    @discardableResult
    func fix(widthHeightRatio: CGFloat?, priority: UILayoutPriority = .required) -> Self {
        /// 移除已经存在的约束
        let existingConstraints = constraints.filter { constraint in
            guard constraint.relation == .equal else { return false }
            guard constraint.firstAttribute == .width else { return false }
            guard constraint.secondAttribute == .height else { return false }
            return true
        }
        /// 移除旧约束
        NSLayoutConstraint.deactivate(existingConstraints)
        /// 添加新约束
        if let widthHeightRatio {
            /// 开启约束
            translatesAutoresizingMaskIntoConstraints = false
            /// 激活约束
            let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: widthHeightRatio)
            constraint.priority = priority
            constraint.isActive = true
        }
        /// 返回自身
        return self
    }
    
    /// 固定尺寸
    /// - Returns: 自己
    @discardableResult func fix(size: CGSize) -> Self {
        fix(width: size.width, height: size.height)
    }
    
    /// 固定宽高
    /// - Returns: 自己
    @discardableResult func fix(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        fix(widthConstraint: width.map(\.constraint), heightConstraint: height.map(\.constraint))
    }
    
    @discardableResult func fix(widthConstraint: UILayoutConstraint? = nil, heightConstraint: UILayoutConstraint? = nil) -> Self {
        
        func deactivateWidthConstraintsIfNeeded() {
            let existingConstraints = constraints.filter { constraint in
                guard constraint.relation == .equal else { return false }
                guard constraint.firstAttribute == .width else { return false }
                guard constraint.secondAttribute == .notAnAttribute else { return false }
                return true
            }
            if existingConstraints.isEmpty { return }
            NSLayoutConstraint.deactivate(existingConstraints)
        }
        
        func deactivateHeightConstraintsIfNeeded() {
            let existingConstraints = constraints.filter { constraint in
                guard constraint.relation == .equal else { return false }
                guard constraint.firstAttribute == .height else { return false }
                guard constraint.secondAttribute == .notAnAttribute else { return false }
                return true
            }
            if existingConstraints.isEmpty { return }
            NSLayoutConstraint.deactivate(existingConstraints)
        }
        
        /// 其中一个必须有值
        guard widthConstraint.isValid || heightConstraint.isValid else {
            /// 如果两个参数都无效, 则移除已经存在的约束
            deactivateWidthConstraintsIfNeeded()
            deactivateHeightConstraintsIfNeeded()
            return self
        }
        /// 开始自动布局
        translatesAutoresizingMaskIntoConstraints = false
        /// 约束宽度
        if let widthConstraint {
            /// 移除存在的约束
            deactivateWidthConstraintsIfNeeded()
            /// 激活新的约束
            let constraint = widthAnchor.constraint(equalToConstant: widthConstraint.constant)
            constraint.priority = widthConstraint.priority
            constraint.isActive = true
        }
        /// 约束高度
        if let heightConstraint {
            /// 移除存在的高度约束
            deactivateHeightConstraintsIfNeeded()
            /// 激活新的约束
            let constraint = heightAnchor.constraint(equalToConstant: heightConstraint.constant)
            constraint.priority = heightConstraint.priority
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult func limit(widthRange: ClosedRange<CGFloat>? = nil, heightRange: ClosedRange<CGFloat>? = nil) -> Self {
        limit(minWidth: widthRange.map(\.lowerBound),
              maxWidth: widthRange.map(\.upperBound),
              minHeight: heightRange.map(\.lowerBound),
              maxHeight: heightRange.map(\.upperBound))
    }
    
    @discardableResult func limit(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil) -> Self {
        limit(minWidth: minWidth.map(\.constraint),
              maxWidth: maxWidth.map(\.constraint),
              minHeight: minHeight.map(\.constraint),
              maxHeight: maxHeight.map(\.constraint))
    }
    
    @discardableResult func limit(minWidth: UILayoutConstraint? = nil, maxWidth: UILayoutConstraint? = nil, minHeight: UILayoutConstraint? = nil, maxHeight: UILayoutConstraint? = nil) -> Self {
        
        func deactivateMinWidthConstraintIfNeeded() {
            let existingConstraints = constraints.filter { constraint in
                guard constraint.relation == .greaterThanOrEqual else { return false }
                guard constraint.firstAttribute == .width else { return false }
                guard constraint.secondAttribute == .notAnAttribute else { return false }
                return true
            }
            if existingConstraints.isEmpty { return }
            NSLayoutConstraint.deactivate(existingConstraints)
        }
        
        func deactivateMaxWidthConstraintIfNeeded() {
            let existingConstraints = constraints.filter { constraint in
                guard constraint.relation == .lessThanOrEqual else { return false }
                guard constraint.firstAttribute == .width else { return false }
                guard constraint.secondAttribute == .notAnAttribute else { return false }
                return true
            }
            if existingConstraints.isEmpty { return }
            NSLayoutConstraint.deactivate(existingConstraints)
        }
        
        func deactivateMinHeightConstraintIfNeeded() {
            let existingConstraints = constraints.filter { constraint in
                guard constraint.relation == .greaterThanOrEqual else { return false }
                guard constraint.firstAttribute == .height else { return false }
                guard constraint.secondAttribute == .notAnAttribute else { return false }
                return true
            }
            if existingConstraints.isEmpty { return }
            NSLayoutConstraint.deactivate(existingConstraints)
        }
        
        func deactivateMaxHeightConstraintIfNeeded() {
            let existingConstraints = constraints.filter { constraint in
                guard constraint.relation == .lessThanOrEqual else { return false }
                guard constraint.firstAttribute == .height else { return false }
                guard constraint.secondAttribute == .notAnAttribute else { return false }
                return true
            }
            if existingConstraints.isEmpty { return }
            NSLayoutConstraint.deactivate(existingConstraints)
        }
        
        /// 先移除已经存在的约束
        deactivateMinWidthConstraintIfNeeded()
        deactivateMaxWidthConstraintIfNeeded()
        deactivateMinHeightConstraintIfNeeded()
        deactivateMaxHeightConstraintIfNeeded()
        /// 开始约束
        translatesAutoresizingMaskIntoConstraints = false
        /// 最小宽度
        if let minWidth {
            /// 激活新的约束
            let constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth.constant)
            constraint.priority = minWidth.priority
            constraint.isActive = true
        }
        /// 最大宽度
        if let maxWidth {
            /// 激活新的约束
            let constraint = widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth.constant)
            constraint.priority = maxWidth.priority
            constraint.isActive = true
        }
        /// 最小高度
        if let minHeight {
            /// 激活新的约束
            let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight.constant)
            constraint.priority = minHeight.priority
            constraint.isActive = true
        }
        /// 最大高度
        if let maxHeight {
            /// 激活新的约束
            let constraint = heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight.constant)
            constraint.priority = maxHeight.priority
            constraint.isActive = true
        }
        return self
    }
	
	/// 添加子视图(可变参数)
	/// - Parameter subviews: 子视图序列
	func addSubviews(_ subviews: UIView...) {
		addSubviews(subviews)
	}
	
	/// 添加子视图(通过@ArrayBuilder创建)
	/// - Parameter builder: 子视图构建方法
	func addSubviews(@ArrayBuilder<UIView> builder: () -> [UIView]) {
		let subviews = builder()
		addSubviews(subviews)
	}
	
	/// 添加子视图集合
	/// - Parameter subviews: UIView集合
	func addSubviews<T>(_ subviews: T) where T: Sequence, T.Element: UIView {
		subviews.forEach { subview in
			addSubview(subview)
		}
	}
	
	/// 自适应Size | 内部子控件Autolayout
	/// 注意: 在设置UITableView.headerView属性的时候,内部控件的约束优先级最好都配置成非.required
    /// 否则可能报Unable to simultaneously satisfy constraints.警告
    /// 如果headerView继承自普通的UIView,调用此方法之前要保证提前设置好宽度约束等于TableView的宽度,否则会得到错误的布局
    /// 或者调用layoutIfNeeded然后重新赋值UITableView.headerView
    ///
    /// 故,最好使用UITableViewHeaderFooterView的子类来设置UITableView的headerView属性,因为其自身就带有宽度等于父视图的约束
    /// 可以省去再次配置宽度约束的步骤
	func fitSizeIfNeeded() {
		let systemLayoutSize = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		let height = systemLayoutSize.height
		let width = systemLayoutSize.width
		// Comparison necessary to avoid infinite loop
		if height != bounds.height {
			bounds.size.height = height
		}
		if width != bounds.width {
			bounds.size.width = width
		}
	}
    
    func superview(where predicate: (UIView) -> Bool) -> UIView? {
        superview(UIView.self, where: predicate)
    }
    
    /// 找到符合条件的父视图
    /// - Parameter predicate: 判断父视图是否合规的判决条件
    /// - Returns: 满足条件的父视图
    func superview<SuperView: UIView>(_ type: SuperView.Type, where predicate: (SuperView) -> Bool) -> SuperView? {
        var targetSuperview: SuperView?
        var nextResponder = next
        while let unwrapResponder = nextResponder {
            if let nextSuperview = unwrapResponder as? SuperView {
                if predicate(nextSuperview) {
                    targetSuperview = nextSuperview
                    break
                }
            }
            nextResponder = unwrapResponder.next
        }
        return targetSuperview
    }
	
	/// 获取父视图
	/// - Parameter type: 父视图类型
	/// - Returns: 有效的父视图
	func superview<SuperView: UIView>(_ type: SuperView.Type) -> SuperView? {
        /// 确保有父视图
		guard let validSuperview = superview else { return nil }
        /// 转换成指定类型的父视图
		guard let matchedSuperview = validSuperview as? SuperView else {
            /// 如果转换失败则查找父视图的parentSuperView
			return validSuperview.superview(SuperView.self)
		}
		return matchedSuperview
	}
	
	/// 硬化 | 不可拉伸 | 不可压缩
	/// - Parameters:
	///   - axis: 设置轴线 | 默认为空(两轴同时硬化)
	///   - intensity: 硬化强度
	/// - Returns: 控件本身
	/// - Tips: 谨慎使用这个方法: 调用这四个方法之后, 会导致UIButtonPlus分类中重写的intrinsicContentSize返回的size失效
	@discardableResult
    func harden(axis: NSLayoutConstraint.Axis? = nil, intensity: UILayoutPriority = .required) -> Self {
        if let axis {
            switch axis {
            case .horizontal:
                hardenHorizontal(intensity)
            case .vertical:
                hardenVertical(intensity)
            @unknown default:
                break
            }
        } else {
            hardenVertical(intensity)
            hardenHorizontal(intensity)
        }
        
		return self
	}
    
    
    /// 垂直方向硬化
    /// - Parameter intensity: 硬化强度
    @discardableResult
    func hardenVertical(_ intensity: UILayoutPriority) -> Self {
        /// 压缩
        setContentCompressionResistancePriority(intensity, for: .vertical)
        /// 拉伸
        setContentHuggingPriority(intensity, for: .vertical)
        return self
    }
    
    /// 水平方向硬化
    /// - Parameter intensity: 硬化强度
    @discardableResult
    func hardenHorizontal(_ intensity: UILayoutPriority) -> Self {
        /// 压缩
        setContentCompressionResistancePriority(intensity, for: .horizontal)
        /// 拉伸
        setContentHuggingPriority(intensity, for: .horizontal)
        return self
    }
	
	// MARK: - __________ 圆角 + 阴影 __________
	var shadowView: _ShadowView {
        guard let shadow = associated(_ShadowView.self, self, Associated.shadowView) else {
			let shadow = _ShadowView(frame: bounds)
			shadow.isUserInteractionEnabled = false
			shadow.backgroundColor = .clear
			shadow.layer.masksToBounds = false
			shadow.layer.shouldRasterize = true
			shadow.layer.rasterizationScale = UIScreen.main.scale
			shadow.autoresizingMask = [
				.flexibleWidth,
				.flexibleHeight
			]
            setAssociatedObject(self, Associated.shadowView, shadow, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return shadow
		}
		return shadow
	}
	
	
	/// 为视图添加圆角和阴影 | 只在frame确定的时候才能调用此方法
	/// - Parameters:
	///   - corners: 圆角效果施加的角
	///   - cornerRadius: 圆角大小
	///   - shadowColor: 阴影颜色: 不为空才添加阴影
	///   - shadowOffsetX: 阴影偏移X
	///   - shadowOffsetY: 阴影偏移Y
	///   - shadowRadius: 阴影大小
	///   - shadowOpacity: 阴影透明度
	///   - shadowExpansion: 阴影扩大值:大于零扩大; 小于零收缩; 0:默认值
	func roundCorners(corners: UIRectCorner = .allCorners,
					  cornerRadius: CGFloat = 0.0,
					  withShadowColor shadowColor: UIColor? = nil,
					  shadowOffset: (x: Double, y: Double) = (0, 0),
					  shadowRadius: CGFloat = 0,
					  shadowOpacity: Float = 0,
					  shadowExpansion: CGFloat = 0) {
		// 圆角
		var bezier = UIBezierPath(
			roundedRect: bounds,
			byRoundingCorners: corners,
			cornerRadii: CGSize(width:cornerRadius, height:cornerRadius)
		)
		if cornerRadius > 0 {
			// 未设置阴影的时候尝试使用iOS 11的API设置圆角
			if #available(iOS 11.0, *), shadowColor == nil {
				// 这个方法在UITableViewCell外部调用时 Section的最后一个Cell不起作用,不清楚为啥
				layer.masksToBounds = true
				layer.cornerRadius = cornerRadius
				layer.maskedCorners = corners.caCornerMask
			} else {
				let shape = CAShapeLayer()
				shape.path = bezier.cgPath
				layer.mask = shape
			}
		} else {
            if #available(iOS 11.0, *), shadowColor == nil {
                // 这个方法在UITableViewCell外部调用时 Section的最后一个Cell不起作用,不清楚为啥
                layer.masksToBounds = false
                layer.cornerRadius = cornerRadius
                layer.maskedCorners = corners.caCornerMask
            } else {
                layer.mask = nil
            }
		}
		
		// 阴影
		if let shadowColor = shadowColor {
			// 调整阴影View的frame
			shadowView.frame = frame
			// 设置阴影属性
			shadowView.layer.shadowColor = shadowColor.cgColor
			shadowView.layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
			shadowView.layer.shadowRadius = shadowRadius
			shadowView.layer.shadowOpacity = shadowOpacity
			// 设置阴影形状
			if shadowExpansion != 0 {
				let insets = UIEdgeInsets(
					top: -shadowExpansion,
					left: -shadowExpansion,
					bottom: -shadowExpansion,
					right: -shadowExpansion
				)
				bezier = UIBezierPath(
					roundedRect: bounds.inset(by: insets),
					byRoundingCorners: corners,
					cornerRadii: CGSize(width:cornerRadius, height:cornerRadius)
				)
			}
			shadowView.layer.shadowPath = bezier.cgPath
			if let superView = superview {
				superView.insertSubview(shadowView, belowSubview: self)
			}
		}
	}
}
// MARK: - __________ SwiftUI __________
#if DEBUG
@available(iOS 13.0, *)
extension UIView {

	var previewLayout: PreviewLayout {
		let previewSize = systemLayoutSizeFitting(
			CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		)
		return .fixed(width: previewSize.width, height: previewSize.height)
	}
	
	private struct Preview: UIViewRepresentable {
		
		let view: UIView

		func makeUIView(context: Context) -> UIView { view }

		func updateUIView(_ uiView: UIView, context: Context) { }
	}

	var preview: some View {
		// 如何遇见切换UIView和UIView(带设备边框)的情况,可尝试把整个项目关闭在重新打开; 或清除Preview缓存:
		// .../Xcode/DerivedData/TargetFolder.../Build/Intermediates.noindex/Previews
		Preview(view: self)
//			.previewLayout(.device)
			.previewLayout(previewLayout)
	}
}
#endif

// MARK: - 其他
extension UIView.AutoresizingMask {
    
    /// 自动根据初始的frame调整尺寸
    static var autoResize: UIView.AutoresizingMask {
        [.flexibleWidth, .flexibleHeight]
    }
}
