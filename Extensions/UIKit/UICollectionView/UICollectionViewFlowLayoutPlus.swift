//
//  UICollectionViewFlowLayoutPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/10/9.
//

import UIKit

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
