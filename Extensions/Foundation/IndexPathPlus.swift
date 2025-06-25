//
//  IndexPathPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/6/13.
//

import UIKit

extension IndexPath {
    /// 第一行
    static let firstRow = IndexPath(row: 0, section: 0)
    /// 第一项
    static let firstItem = IndexPath(item: 0, section: 0)
    
    /// section转换成IndexSet
    var sectionIndexSet: IndexSet {
        guard count >= 1 else { return .empty }
        return IndexSet(integer: section)
    }
    
    /// row转换成IndexSet
    var rowIndexSet: IndexSet {
        guard count >= 2 else { return .empty }
        return IndexSet(integer: row)
    }
    
    /// item转换成IndexSet
    var itemIndexSet: IndexSet {
        guard count >= 2 else { return .empty }
        return IndexSet(integer: item)
    }
    
    /// 验证IndexPath在指定TableView中是否有效
    /// - Returns: 有效的IndexPath
    func validIndexPath(for tableView: UITableView) -> IndexPath? {
        guard section >= 0, row >= 0 else { return nil }
        guard section < tableView.numberOfSections, row < tableView.numberOfRows(inSection: section) else { return nil }
        return self
    }
    
    /// 验证IndexPath在指定CollectionView中是否有效
    /// - Parameter collectionView: 目标CollectionView
    /// - Returns: CollectionView中有效的IndexPath
    func validIndexPath(in collectionView: UICollectionView) -> IndexPath? {
        guard section >= 0, item >= 0 else { return nil }
        guard section < collectionView.numberOfSections, item < collectionView.numberOfItems(inSection: section) else { return nil }
        return self
    }
}

extension IndexPath: @retroactive ExpressibleByIntegerLiteral {
    public init(integerLiteral element: Element) {
        self.init(index: element)
    }
}

extension Sequence where Element == IndexPath {
    
    /// 将所有IndexPath的section放入IndexSet
    var sectionIndexSet: IndexSet {
        reduce(into: IndexSet.empty) { accumulation, next in
            guard let section = next.first else { return }
            accumulation.insert(section)
        }
    }
    
    /// 将所有IndexPath的item放入IndexSet
    var itemIndexSet: IndexSet {
        do {
            var sectionSet = Set<Int>.empty
            return try reduce(into: IndexSet.empty) { accumulation, next in
                guard next.count >= 2 else {
                    return dprint("Path深度不足")
                }
                sectionSet.insert(next.section)
                if sectionSet.count > 1 {
                    throw "Multiple section items in one IndexSet don't make sense."
                }
                accumulation.insert(next.item)
            }
        } catch {
            assertionFailure("Error: \(error)")
            return .empty
        }
    }
}
