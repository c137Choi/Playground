//
//  UIViewController+Rx.swift
//  RxPlayground
//
//  Created by Choi on 2021/4/15.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
	
    var viewWillTransitionTo: ControlEvent<(CGSize, UIViewControllerTransitionCoordinator)> {
        let events = methodInvoked(#selector(Base.viewWillTransition(to:with:))).compactMap {
            parameters -> (CGSize, UIViewControllerTransitionCoordinator)? in
            guard let targetSize = parameters.element(at: 0) as? CGSize else { return nil }
            guard let coordinator = parameters.element(at: 1) as? UIViewControllerTransitionCoordinator else { return nil }
            return (targetSize, coordinator)
        }
        return ControlEvent(events: events)
    }
    
	var viewDidLoad: ControlEvent<Void> {
		let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
		return ControlEvent(events: source)
	}
    
    var viewWillAppearOnce: RxObservable<Bool> {
        viewWillAppear.take(1)
    }
    
	var viewWillAppear: ControlEvent<Bool> {
		let source = methodInvoked(#selector(Base.viewWillAppear))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
    
    var viewDidAppearOnce: RxObservable<Bool> {
        viewDidAppear.take(1)
    }
    
	var viewDidAppear: ControlEvent<Bool> {
		let source = methodInvoked(#selector(Base.viewDidAppear))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
	
	var viewWillDisappear: ControlEvent<Bool> {
		let source = methodInvoked(#selector(Base.viewWillDisappear))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
    
	var viewDidDisappear: ControlEvent<Bool> {
		let source = methodInvoked(#selector(Base.viewDidDisappear))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
	
	var viewWillLayoutSubviews: ControlEvent<Void> {
		let source = methodInvoked(#selector(Base.viewWillLayoutSubviews))
			.map { _ in }
		return ControlEvent(events: source)
	}
    
	var viewDidLayoutSubviews: ControlEvent<Void> {
		let source = methodInvoked(#selector(Base.viewDidLayoutSubviews))
			.map { _ in }
		return ControlEvent(events: source)
	}
	
	var willMoveToParentViewController: ControlEvent<UIViewController?> {
		let source = methodInvoked(#selector(Base.willMove))
			.map { $0.first as? UIViewController }
		return ControlEvent(events: source)
	}
    
	var didMoveToParentViewController: ControlEvent<UIViewController?> {
		let source = methodInvoked(#selector(Base.didMove))
			.map { $0.first as? UIViewController }
		return ControlEvent(events: source)
	}
	
	var didReceiveMemoryWarning: ControlEvent<Void> {
		let source = methodInvoked(#selector(Base.didReceiveMemoryWarning))
			.map { _ in }
		return ControlEvent(events: source)
	}
	
    /// 视图控制器的viewWillAppear/viewWillDisappear方法映射出view是否可见的序列 | 比viewDidVisible提前一些
    var viewWillVisible: RxObservable<Bool> {
        let willAppear = viewWillAppear.mapDesignated(true)
        let willDisappear = viewWillDisappear.mapDesignated(false)
        return RxObservable<Bool>.merge(willAppear, willDisappear).startWith(base.view.isVisible)
    }
    
	/// 视图控制器的viewDidAppear/viewDidDisappear方法映射出view是否可见的序列
	var viewDidVisible: RxObservable<Bool> {
		let didAppear = viewDidAppear.mapDesignated(true)
        let didDisappear = viewDidDisappear.mapDesignated(false)
		return RxObservable<Bool>.merge(didAppear, didDisappear).startWith(base.view.isVisible)
	}
	
	//表示页面被释放的可观察序列，当VC被dismiss时会触发
	var isDismissing: ControlEvent<Bool> {
		let source = sentMessage(#selector(Base.dismiss))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
}
