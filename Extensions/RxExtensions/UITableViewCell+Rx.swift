//
//  UITableViewCell+Rx.swift
//  RxPlayground
//
//  Created by Choi on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableViewCell {
    var prepareForReuse: RxObservable<[Any]> {
        methodInvoked(#selector(UITableViewCell.prepareForReuse))
    }
}
