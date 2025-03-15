//
//  Optional+Rx.swift
//  KnowLED
//
//  Created by Choi on 2024/5/16.
//

import Foundation
import RxSwift
import RxCocoa

extension Optional {
    
    func assign(to binders: Binder<Self>...) {
        assign(to: binders)
    }
    func assign(to binders: [Binder<Self>]) {
        binders.forEach { binders in
            binders.onNext(self)
        }
    }
    
    /// 只设置有效值
    func assignUnwrapped(to binders: Binder<Self>...) {
        assignUnwrapped(to: binders)
    }
    func assignUnwrapped(to binders: [Binder<Self>]) {
        guard let unwrapped = self else { return }
        binders.forEach { binders in
            binders.onNext(unwrapped)
        }
    }
    
    func assign(to binders: Binder<Wrapped>...) {
        assign(to: binders)
    }
    func assign(to binders: [Binder<Wrapped>]) {
        if case .some(let wrapped) = self {
            binders.forEach { binder in
                binder.onNext(wrapped)
            }
        }
    }
}
