//
//  SKNode+Rx.swift
//  KnowLED
//
//  Created by Choi on 2023/9/15.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa

extension Reactive where Base: SKNode {
    
    /// 从父节点移除事件序列 | 元素: 节点本身
    var removeFromParent: Observable<Base> {
        methodInvoked(#selector(base.removeFromParent))
            .withUnretained(base)
            .map(\.0)
    }
    
    var position: Observable<CGPoint> {
        observe(\.position, options: .live)
    }
}
