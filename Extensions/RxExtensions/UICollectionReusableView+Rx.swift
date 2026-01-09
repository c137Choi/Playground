//
//  UICollectionReusableView+Rx.swift
//
//  Created by Choi on 2023/5/20.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UICollectionReusableView {
    
    /// 因为UICollectionViewCell也继承自UICollectionReusableView
    /// 所以UICollectionViewCell也用这个属性
    var reusedOrDeallocated: RxObservable<Any> {
        RxObservable<Any>.merge {
            methodInvoked(#selector(UICollectionReusableView.prepareForReuse)).anyElement
            deallocated.anyElement
        }
    }
}
