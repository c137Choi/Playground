//
//  UITableView+Rx.swift
//
//  Created by Choi on 2022/8/22.
//

import UIKit
import RxSwift
import RxCocoa

extension UITableView {
    
    /// 监听 | 刷新之后重新选中之前的选中行
    /// 只有latestSelectedIndexPaths订阅的时候这个方法才会调用
    fileprivate func observeToReselect() {
        /// 这里可以获取到正常的indexPathsForSelectedRows
        /// 可见这里的时间节点是在reloadData之前的
        guard let lastSelected = indexPathsForSelectedRows else { return }
        _ = rx.didReloadData.once.bind { emitedTable in
            emitedTable.rx.selectedIndexPaths.onNext(lastSelected)
        }
    }
    
    /// 最新选中的IndexPaths
    fileprivate var latestSelectedIndexPaths: RxObservable<[IndexPath]> {
        rx.indexPathsAfterSelectionChanged
            .do(onSubscribe: observeToReselect)
            .startWith(indexPathsForSelectedRows.orEmpty)
    }
    
    /// 检查是否选中所有行
    /// - Parameter selectedIndexPaths: 选中行
    /// - Returns: 是否全部选中
    fileprivate func checkAllRowsSelected(_ selectedIndexPaths: [IndexPath]) -> Bool {
        selectedIndexPaths.isEmpty ? false : selectedIndexPaths.count == numberOfRows
    }
}

extension Reactive where Base: UITableView {
    
    var shouldHideScrollBar: RxObservable<Bool> {
        didLayoutSubviews.map(\.shouldHideScrollBar)
    }
    
    var numberOfRows: RxObservable<Int> {
        didReloadData.map(\.numberOfRows)
    }
    
    var isAllRowsSelected: Driver<Bool> {
        selectedIndexPaths
            .map(base.checkAllRowsSelected)
            .startWith(false)
            .removeDuplicates
            .asDriver(onErrorJustReturn: false)
    }
    
    /// 选中的IndexPaths
    fileprivate var observeSelectedIndexPaths: RxObservable<[IndexPath]> {
        willReloadData.startWith(base).flatMapLatest(\.latestSelectedIndexPaths)
    }
    fileprivate var selectedIndexPathsBinder: Binder<[IndexPath]> {
        Binder(base) { table, selectedIndexPaths in
            guard selectedIndexPaths != table.indexPathsForSelectedRows else { return }
            selectedIndexPaths.forEach { indexPath in
                table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    var selectedIndexPaths: ControlProperty<[IndexPath]> {
        ControlProperty(values: observeSelectedIndexPaths, valueSink: selectedIndexPathsBinder)
    }
    
    /// 调用reloadData之后的通知
    var didReloadData: RxObservable<Base> {
        methodInvoked(#selector(base.reloadData))
            .withUnretained(base)
            .map(\.0)
    }
    
    /// 调用reloadData之前的通知
    var willReloadData: RxObservable<Base> {
        sentMessage(#selector(base.reloadData))
            .withUnretained(base)
            .map(\.0)
    }
    
    fileprivate var indexPathsAfterSelectionChanged: RxObservable<[IndexPath]> {
        rowSelectionChanged
            .withUnretained(base)
            .map(\.0.indexPathsForSelectedRows.orEmpty)
    }
    
    private var rowSelectionChanged: RxObservable<IndexPath> {
        RxObservable.merge(selectRowAt, itemSelected.observable, itemDeselected.observable)
    }
    
    private var selectRowAt: RxObservable<IndexPath> {
        methodInvoked(#selector(base.selectRow(at:animated:scrollPosition:)))
            .compactMap(\.first)
            .as(IndexPath.self)
    }
}
