//
//  UITableViewHeaderFooterView+Rx.swift
//
//  Created by Choi on 2023/5/4.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableViewHeaderFooterView {
    var prepareForReuse: RxObservable<[Any]> {
        methodInvoked(#selector(UITableViewHeaderFooterView.prepareForReuse))
    }
}
