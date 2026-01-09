//
//  UITableViewHeaderFooterView+Rx.swift
//
//  Created by Choi on 2023/5/4.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableViewHeaderFooterView {
    
    var reusedOrDeallocated: RxObservable<Any> {
        RxObservable<Any>.merge {
            methodInvoked(#selector(UITableViewHeaderFooterView.prepareForReuse)).anyElement
            deallocated.anyElement
        }
    }
}
