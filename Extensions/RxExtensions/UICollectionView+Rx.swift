//
//  UICollectionView+Rx.swift
//
//  Created by Choi on 2022/9/21.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UICollectionView {
    
    var page: ControlProperty<Int> {
        let finalOffset = didEndDecelerating.withUnretained(base).map(\.0.contentOffset)
        let targetOffset = willEndDragging.map(\.targetContentOffset.pointee)
        let mergedOffset = RxObservable.merge(finalOffset, targetOffset)
        
        let observedPage = mergedOffset.withUnretained(base).map { collectionView, offset in
            let contentSize = collectionView.contentSize
            var axis = NSLayoutConstraint.Axis.horizontal
            if contentSize.height > collectionView.bounds.height {
                axis = .vertical
            }
            switch axis {
            case .horizontal:
                guard collectionView.bounds.width > 0 else { return 0 }
                return Int(offset.x / collectionView.bounds.width)
            case .vertical:
                guard collectionView.bounds.height > 0 else { return 0 }
                return Int(offset.y / collectionView.bounds.height)
            @unknown default:
                return 0
            }
        }
            .distinctUntilChanged()
        
        let binder = Binder(base) { collectionView, page in
            guard 0... ~= page else { return }
            let contentSize = collectionView.contentSize
            var axis = NSLayoutConstraint.Axis.horizontal
            if contentSize.height > collectionView.bounds.height {
                axis = .vertical
            }
            switch axis {
            case .horizontal:
                collectionView.contentOffset = CGPoint(x: page.double * collectionView.bounds.width, y: 0)
            case .vertical:
                collectionView.contentOffset = CGPoint(x: 0, y: page.double * collectionView.bounds.height)
            @unknown default:
                break
            }
        }
        return ControlProperty(values: observedPage, valueSink: binder)
    }
    
    var numberOfItems: RxObservable<Int> {
        dataReloaded.map { collectionView in
            guard let dataSource = collectionView.dataSource else { return 0 }
            guard let sectionCount = dataSource.numberOfSections?(in: base) else { return 0 }
            return (0..<sectionCount).reduce(0) { partialResult, section in
                partialResult + dataSource.collectionView(base, numberOfItemsInSection: section)
            }
        }
    }
    
    var dataReloaded: RxObservable<Base> {
        methodInvoked(#selector(UICollectionView.reloadData))
            .withUnretained(base)
            .map(\.0)
    }
    
    /// reloadData调用之后, 最新的选中的IndexPath数组
    /// 必须在设置了delegate之后订阅才能订阅到itemSelectionChanged里的
    /// delegateInvokedItemSelected, delegateInvokedItemDeselected事件
    /// 如果要实现大量数据的全选/反选功能,需要单独处理选中的IndexPath并在更新之后刷新CollectionView以保证高性能
    var liveSelectedIndexPaths: RxObservable<[IndexPath]> {
        /// 这里使用.startWith(base)操作符是为了保证在任何时间订阅都能产生事件序列
        dataReloaded
            .startWith(base)
            .distinctUntilChanged()
            .flatMapLatest { collectionView in
                itemSelectionChanged
                    .withUnretained(collectionView)
                    .map(\.0.indexPathsForSelectedItems.orEmpty)
                    .startWith(collectionView.indexPathsForSelectedItems.orEmpty)
            }
    }
    
    /// 非实时的: 代码执行选中/取消选中 & 代理执行选中/取消选中之后
    /// 映射indexPathsForSelectedItems属性. 如果为空则返回空数组
    var selectedIndexPaths: RxObservable<[IndexPath]> {
        itemSelectionChanged
            .withUnretained(base)
            .map(\.0.indexPathsForSelectedItems.orEmpty)
            .startWith(base.indexPathsForSelectedItems.orEmpty)
    }
    
    var itemSelectionChanged: RxObservable<IndexPath> {
        RxObservable<IndexPath>.merge {
            /// 代码执行选中
            selectItemAtIndexPath
            /// 代码执行取消选中
            deselectItemAtIndexPath
            /// 代理执行选中
            delegateDidSelectItemAtIndexPath
            /// 代理执行取消选中
            delegateDidDeselectItemAtIndexPath
        }
    }
    
    var delegateDidSelectItemAtIndexPath: RxObservable<IndexPath> {
        itemSelected.observable
    }
    
    var delegateDidDeselectItemAtIndexPath: RxObservable<IndexPath> {
        itemDeselected.observable
    }
    
    /// Instance method selectItem(at:animated:scrollPosition:) invoked
    /// Element: The input indexPath
    /// Tip: The method doesn’t cause any selection-related delegate methods to be called.
    var selectItemAtIndexPath: RxObservable<IndexPath> {
        methodInvoked(#selector(UICollectionView.selectItem(at:animated:scrollPosition:)))
            .map(\.first)
            .unwrapped
            .compactMap(IndexPath.self)
    }
    
    /// Instance method deselectItem(at:animated:) invoked
    /// Element: The input deselected indexPath
    /// Tip: The method doesn’t cause any selection-related delegate methods to be called.
    var deselectItemAtIndexPath: RxObservable<IndexPath> {
        methodInvoked(#selector(UICollectionView.deselectItem(at:animated:)))
            .map(\.first)
            .unwrapped
            .compactMap(IndexPath.self)
    }
}
