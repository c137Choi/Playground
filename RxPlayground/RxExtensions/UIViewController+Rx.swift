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
    var viewWillAppearOnce: Observable<Bool> {
        viewWillAppear.take(1)
    }
	var viewWillAppear: ControlEvent<Bool> {
		let source = methodInvoked(#selector(Base.viewWillAppear))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
    var viewDidAppearOnce: Observable<Bool> {
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
	
	//表示视图是否显示的可观察序列，当VC显示状态改变时会触发
	var isVisible: Observable<Bool> {
		let viewDidAppearObservable = viewDidAppear.map { _ in true }
		let viewWillDisappearObservable = viewWillDisappear.map { _ in false }
		return Observable<Bool>
            .merge(viewDidAppearObservable, viewWillDisappearObservable)
            .startWith(false)
	}
	
	//表示页面被释放的可观察序列，当VC被dismiss时会触发
	var isDismissing: ControlEvent<Bool> {
		let source = sentMessage(#selector(Base.dismiss))
			.map { $0.first as? Bool ?? false }
		return ControlEvent(events: source)
	}
}
