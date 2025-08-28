//
//  UITextView+Rx.swift
//
//  Created by Choi on 2023/2/22.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextView {
    
    var unmarkedText: Observable<String> {
        didChange
            .withUnretained(base)
            .map(\.0.unmarkedText)
            .orEmpty
            .removeDuplicates
    }
}
