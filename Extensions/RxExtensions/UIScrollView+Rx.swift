//
//  UIScrollView+Rx.swift
//  RxPlayground
//
//  Created by Choi on 2021/4/30.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    /// 是否在指定方向上隐藏滚动条
    /// - Parameter direction: 滚动方向
    func shouldHideScrollBar(at direction: UICollectionView.ScrollDirection) -> RxObservable<Bool> {
        didLayoutSubviews.map {
            $0.shouldHideScrollBar(at: direction)
        }
    }
    
    /// 合并事件
    /// 用于更新自定义滚动条
    var contentSizeAndVisibleContentBounds: RxObservable<(CGSize, CGRect)> {
        RxObservable.combineLatest(contentSize, visibleContentBounds)
    }
    
    var contentSize: ControlProperty<CGSize> {
        let binder = Binder(base) { scroll, newContentSize in
            guard newContentSize != scroll.contentSize else { return }
            scroll.contentSize = newContentSize
        }
        return ControlProperty(values: observedContentSize, valueSink: binder)
    }
    
    /// KVO contentSize
    /// 如果在UITableView中使用固定行高,则需要将
    /// estimatedHeightForRowAt
    /// estimatedHeightForHeader
    /// estimatedHeightForFooter
    /// 都设置成比固定高度大的值,才能避免出现返回的尺寸跳变的问题
    var observedContentSize: RxObservable<CGSize> {
        observe(\.contentSize, options: .live).removeDuplicates
    }
    
    /// 实时的ContentOffset
    /// RxCocoa里带的那个contentOffset: ControlProperty<CGPoint> 使用起来有点问题:
    /// 如果在设置delegate之前订阅contentOffset, 之后再设置delegate属性, 则订阅只会输出初始值, 后续不再更新值.
    /// 如果只订阅contentOffset, 后面不设置delegate属性就没问题, 但通常Tableview, CollectionView都会设置delegate属性的
    /// 如果在设置了delegate之后再次订阅此属性才可以正常订阅到offset.
    /// 并且如果在设置delegate前后都订阅了此属性, 那么前后两次订阅都可以订阅到更新的offset
    /// 所以为保险起见, 重新用visibleContentBounds的origin作为values重新生成一个ControlProperty
    var liveContentOffset: ControlProperty<CGPoint> {
        ControlProperty(values: visibleContentBounds.map(\.origin), valueSink: contentOffset)
    }
    
    /// base.contentOffset +
    /// base.bounds.size
    var visibleContentBounds: RxObservable<CGRect> {
        didLayoutSubviews.map(\.bounds)
    }
    
	var reachedBottom: Signal<()> {
		contentOffset.asDriver()
			.flatMap { [weak base] contentOffset -> Signal<()> in
				guard let scrollView = base else { return .empty() }
				// 可视区域高度
				let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
				// 滚动条最大位置
				let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
				// 如果当前位置超出最大位置则发出一个事件
				let y = contentOffset.y + scrollView.contentInset.top
				return y > threshold ? Signal.just(()) : Signal.empty()
			}
	}
}
