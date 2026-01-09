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
    
    var reusedOrDeallocated: RxObservable<Any> {
        RxObservable<Any>.merge {
            methodInvoked(#selector(UITableViewCell.prepareForReuse)).anyElement
            deallocated.anyElement
        }
    }
}
