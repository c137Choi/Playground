//
//  UIButton+Rx.swift
//
//  Created by Choi on 2022/8/4.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    
    var tapButton: Observable<Base> {
        tap.compactMap {
            [weak base] _ in base
        }
    }
    
    var normalTitle: Binder<String?> {
        title(for: .normal)
    }
    
    var selectedTitle: Binder<String?> {
        title(for: .selected)
    }
    
    var highlightedTitle: Binder<String?> {
        title(for: .highlighted)
    }
    
    var normalImage: Binder<UIImage?> {
        image(for: .normal)
    }
    
    var selectedImage: Binder<UIImage?> {
        image(for: .selected)
    }
    
    var highlightedImage: Binder<UIImage?> {
        image(for: .highlighted)
    }
    
    /// 限制按钮连续点击
    /// 时间:800毫秒
    var throttledTap: Observable<Void> {
        tap.throttle(.milliseconds(800), latest: false, scheduler: MainScheduler.instance)
    }
}
