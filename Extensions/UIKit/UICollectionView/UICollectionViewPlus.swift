//
//  UICollectionViewPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/3/15.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    /// 选中前检查IndexPath
    func safeSelectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        /// 非空IndexPath
        if let indexPath {
            /// 检测IndexPath
            guard let validIndexPath = indexPath.validIndexPath(in: self) else { return }
            /// 检测通过后设置选中项
            selectItem(at: validIndexPath, animated: animated, scrollPosition: scrollPosition)
        }
        /// 如果为空则表示要清空当前选中项, 直接调用方法
        else {
            selectItem(at: nil, animated: animated, scrollPosition: scrollPosition)
        }
    }
    
    /// 刷新项目
    /// - Parameter indexPath: 要刷新的IndexPath
    func reloadItem(at indexPath: IndexPath) {
        reloadItems(at: [indexPath])
    }
    
    /// 判断分组内的Item是否全部选中
    /// - Parameter section: 分组(0 indexed)
    /// - Returns: 分组内的Item是否全部选中
    func isAllItemSelectedInSection(_ section: Int) -> Bool {
        /// 取出所有选中的IndexPath
        guard let selectedIndexPaths = indexPathsForSelectedItems else {
            return false
        }
        /// 过滤出指定分组的IndexPath
        let selectedSectionIndexPaths = selectedIndexPaths.filter { indexPath in
            indexPath.section == section
        }
        /// 对比指定分组选中的IndexPath数量是否和分组内的Item数量相等
        return numberOfItems(inSection: section) == selectedSectionIndexPaths.count
    }
    
    /// 判断是否所有Item都被选中
    var isAllItemSelected: Bool {
        /// 取出所有选中的IndexPath
        guard let selectedIndexPaths = indexPathsForSelectedItems else {
            return false
        }
        return numberOfItems == selectedIndexPaths.count
    }
    
    /// 所有Item的数量
    var numberOfItems: Int {
        (0..<numberOfSections).reduce(0) { itemCount, section in
            itemCount + numberOfItems(inSection: section)
        }
    }
}


extension UICollectionView.ScrollPosition {
    
    static var none: UICollectionView.ScrollPosition {
        []
    }
}
