//
//  UICollectionViewPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/3/15.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

extension UICollectionReusableView {
	enum SupplementaryViewKind {
		case header
		case footer
        case custom(String)
		var raw: String {
            switch self {
            case .header: return UICollectionView.elementKindSectionHeader
            case .footer: return UICollectionView.elementKindSectionFooter
            case .custom(let kind): return kind
            }
		}
        init(rawValue: String) {
            if rawValue == UICollectionView.elementKindSectionHeader {
                self = .header
            } else if rawValue == UICollectionView.elementKindSectionFooter {
                self = .footer
            } else {
                self = .custom(rawValue)
            }
        }
	}
	static func registerTo(_ collectionView: UICollectionView, kind: SupplementaryViewKind) {
		collectionView.register(self, forSupplementaryViewOfKind: kind.raw, withReuseIdentifier: Self.reuseId)
	}
	static func dequeReusableSupplementaryView(from collectionView: UICollectionView, kind: SupplementaryViewKind, indexPath: IndexPath) -> Self {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind.raw, withReuseIdentifier: Self.reuseId, for: indexPath) as! Self
	}
}

extension UICollectionViewCell {
	static func registerTo(_ collectionView: UICollectionView) {
		collectionView.register(self, forCellWithReuseIdentifier: reuseId)
	}
	static func dequeueReusableCell(from collectionView: UICollectionView, indexPath: IndexPath) -> Self {
		collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseId, for: indexPath) as! Self
	}
}


extension UICollectionViewFlowLayout {
    
    // MARK: - 先从代理方法里获取各项参数 | 再使用默认属性
    
    func itemSizeAt(_ indexPath: IndexPath) -> CGSize {
        guard let collectionView else { return .zero }
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return itemSize }
        return delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? itemSize
    }
    
    func sectionInsetsAt(_ indexPath: IndexPath) -> UIEdgeInsets {
        guard let collectionView else { return sectionInset }
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return sectionInset }
        return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: indexPath.section) ?? sectionInset
    }
    
    func minimumInteritemSpacingForSectionAt(_ indexPath: IndexPath) -> CGFloat {
        guard let collectionView else { return minimumInteritemSpacing }
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return minimumInteritemSpacing }
        return delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: indexPath.section) ?? minimumInteritemSpacing
    }
    
    func minimumLineSpacingForSectionAt(_ indexPath: IndexPath) -> CGFloat {
        guard let collectionView else { return minimumLineSpacing }
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return minimumLineSpacing }
        return delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: indexPath.section) ?? minimumLineSpacing
    }
}

extension UICollectionView {
    
    /// 选中前检查IndexPath
    func safeSelectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        let checkedIndexPath = indexPath.flatMap {
            $0.validIndexPath(for: self)
        }
        selectItem(at: checkedIndexPath, animated: animated, scrollPosition: scrollPosition)
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
