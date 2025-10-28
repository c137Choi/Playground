//
//  UIButton+Rx.swift
//
//  Created by Choi on 2022/8/4.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    
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
    var throttledTap: RxObservable<Void> {
        tap.throttle(.milliseconds(800), latest: false, scheduler: MainScheduler.instance)
    }
}
