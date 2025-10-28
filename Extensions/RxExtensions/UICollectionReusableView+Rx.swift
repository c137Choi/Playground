//
//  UICollectionReusableView+Rx.swift
//
//  Created by Choi on 2023/5/20.
//

import UIKit
import RxSwift
import RxCocoa

/// 因为UICollectionViewCell也继承自UICollectionReusableView
/// 所以UICollectionViewCell也用这个属性

extension Reactive where Base: UICollectionReusableView {
    var prepareForReuse: RxObservable<[Any]> {
        methodInvoked(#selector(UICollectionReusableView.prepareForReuse))
    }
}
