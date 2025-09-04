//
//  UITableViewPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/3/15.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

extension UITableView {
	
    var shouldHideScrollBar: Bool {
        shouldHideScrollBar(at: .vertical)
    }
    
    var numberOfRows: Int {
        (0..<numberOfSections).reduce(0) { rowCount, section in
            rowCount + numberOfRows(inSection: section)
        }
    }
    
    /// 执行TableView的reloadData并保持之前的contentOffset
    /// 实现手指下拉时刷新保持页面流畅
    public func reloadDataWhileKeepContentOffset() {
        UIView.performWithoutAnimation {
            let previousLocation = contentOffset
            reloadData()
            contentOffset = previousLocation
        }
    }
    
    /// 选中前检查IndexPath
    public func safeSelectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        let checkedIndexPath = indexPath.flatMap {
            $0.validIndexPath(for: self)
        }
        selectRow(at: checkedIndexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    public func selectRows(at indexPaths: [IndexPath] = [], animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none) {
        for indexPath in indexPaths {
            if let indexPathsForSelectedRows, indexPathsForSelectedRows.contains(indexPath) {
                continue
            }
            selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }

    public func deselectRows(at indexPaths: [IndexPath], animated: Bool = true) {
        for indexPath in indexPaths {
            deselectRow(at: indexPath, animated: animated)
        }
    }
    
    func performAllCellSelection(_ performSelection: Bool) {
        for section in 0..<numberOfSections {
            for row in 0..<numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if performSelection {
                    _ = delegate?.tableView?(self, willSelectRowAt: indexPath)
                    selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    delegate?.tableView?(self, didSelectRowAt: indexPath)
                } else {
                    _ = delegate?.tableView?(self, willDeselectRowAt: indexPath)
                    deselectRow(at: indexPath, animated: false)
                    delegate?.tableView?(self, didDeselectRowAt: indexPath)
                }
            }
        }
    }
    
    /// 在视图控制器的viewDidLayoutSubviews方法里调用此方法
    /// 可以对内部添加了约束的tableHeaderView/tableFooterView根据其约束调整尺寸
	func layoutHeaderFooterViewIfNeeded() {
		if let headerView = tableHeaderView {
			let targetSize = CGSize(width: bounds.size.width, height: UIView.layoutFittingCompressedSize.height)
			let compressedSize = headerView.systemLayoutSizeFitting(targetSize)
            if headerView.frame.size != compressedSize {
                headerView.frame.size = compressedSize
                tableHeaderView = headerView
            }
		}
		if let footerView = tableFooterView {
			let targetSize = CGSize(width: bounds.size.width, height: UIView.layoutFittingCompressedSize.height)
			let compressedSize = footerView.systemLayoutSizeFitting(targetSize)
            if footerView.frame.size != compressedSize {
                footerView.frame.size = compressedSize
                tableFooterView = footerView
            }
		}
	}
}

// MARK: - Choi<UITableView>
extension Choi where Base: UITableView {
    
    /// 刷新列表
    /// - Parameter keepLastSelections: 重新选择上次选中的行
    func reloadData(keepLastSelections: Bool) {
        if keepLastSelections, let lastSelections = base.indexPathsForSelectedRows {
            base.reloadData()
            lastSelections.forEach { indexPath in
                base.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            base.reloadData()
        }
    }
}
