//
//  UIPageControl+Rx.swift
//
//  Created by Choi on 2023/5/15.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIPageControl {
    
    var isFirstPage: Observable<Bool> {
        currentPage.map(\.isZero)
    }
    
    var isLastPage: Observable<Bool> {
        currentPage.withUnretained(base).map { pageControl, page in
            page == pageControl.numberOfPages - 1
        }
    }
    
    var currentPage: ControlProperty<Int> {
        /// 监听直接赋值的情况
        let observedCurrentPage = observe(\.currentPage)
        /// 监听滑动触发的情况
        let currentPage = controlEvent(.valueChanged)
            .withUnretained(base)
            .map(\.0.currentPage)
        let mergedCurrentPage = Observable.merge(observedCurrentPage, currentPage).removeDuplicates
        let binder = Binder(base) { pageControl, page in
            guard page != pageControl.currentPage else { return }
            pageControl.currentPage = page
        }
        return ControlProperty(values: mergedCurrentPage, valueSink: binder)
    }
}
