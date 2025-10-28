//
//  UIGestureRecognizer+Rx.swift
//  KnowLED
//
//  Created by Choi on 2025/3/24.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIGestureRecognizer {
    
    var mergedTouchesWithEvent: RxObservable<TouchesWithEvent> {
        RxObservable<TouchesWithEvent>.merge {
            touchesBegan
            touchesMoved
            touchesEnded
            touchesCancelled
        }
    }
    
    var touchesBegan: RxObservable<TouchesWithEvent> {
        methodInvoked(#selector(base.touchesBegan(_:with:))).compactMap { parameters in
            guard let touches = parameters.first as? Set<UITouch> else { return nil }
            return (touches, parameters.last as? UIEvent)
        }
    }
    
    var touchesMoved: RxObservable<TouchesWithEvent> {
        methodInvoked(#selector(base.touchesMoved(_:with:))).compactMap { parameters in
            guard let touches = parameters.first as? Set<UITouch> else { return nil }
            return (touches, parameters.last as? UIEvent)
        }
    }
    
    var touchesEnded: RxObservable<TouchesWithEvent> {
        methodInvoked(#selector(base.touchesEnded(_:with:))).compactMap { parameters in
            guard let touches = parameters.first as? Set<UITouch> else { return nil }
            return (touches, parameters.last as? UIEvent)
        }
    }
    
    var touchesCancelled: RxObservable<TouchesWithEvent> {
        methodInvoked(#selector(base.touchesCancelled(_:with:))).compactMap { parameters in
            guard let touches = parameters.first as? Set<UITouch> else { return nil }
            return (touches, parameters.last as? UIEvent)
        }
    }
}
