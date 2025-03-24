//
//  TouchPhaseRecognizer.swift
//  KnowLED
//
//  Created by Choi on 2025/3/24.
//

import UIKit
import RxSwift
import RxCocoa

struct TouchPhaseSnapshot {
    let phase: UITouch.Phase
    var view: UIView?
}

protocol TouchPhaseRecognizer {
    var phase: UITouch.Phase { get }
    var view: UIView? { get }
}

extension TouchPhaseRecognizer {
    /// 使用快照记录点击状态, 否则使用lastAndLatest操作符获取phase时会返回同一状态
    /// 因为像UITouch/UIGestureRecognizer都是引用类型, lastAndLatest会获取到同一对象
    /// 而且出了对应的作用域之后状态都同步成最新状态了
    var touchPhaseSnapshot: TouchPhaseSnapshot {
        TouchPhaseSnapshot(phase: phase, view: view)
    }
}

extension UITouch: TouchPhaseRecognizer {}

extension UIGestureRecognizer: TouchPhaseRecognizer {
    var phase: UITouch.Phase {
        state.phase
    }
}

// MARK: - Rx
extension ObservableConvertibleType where Element == TouchPhaseSnapshot {
    
    /// 只处理指定视图的子视图或间接子视图
    /// - Parameter superView: 指定父视图
    func filterDescendant(of superView: UIView) -> Observable<Element> {
        observable.filter {
            [weak superView] element in
            guard let superView, let descendant = element.view else { return false }
            return descendant.isDescendant(of: superView)
        }
    }
}
