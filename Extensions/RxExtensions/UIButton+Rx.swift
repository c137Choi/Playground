//
//  UIButton+Rx.swift
//
//  Created by Choi on 2022/8/4.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    
    /// 限制按钮连续点击
    /// 时间:800毫秒
    var throttledTap: RxObservable<Void> {
        tap.throttle(.milliseconds(800), latest: false, scheduler: MainScheduler.instance)
    }
}
