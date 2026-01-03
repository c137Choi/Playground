//
//  UIViewControllerPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/3/3.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import RxSwift
import RxCocoa

extension UIViewController {
    
    /// Dismiss所有的presentedViewController | 最后dismiss自己
    func dismissPresentedViewControllerIfNeeded(_ completion: SimpleCallback? = nil) {
        if let presentedViewController {
            /// 不加动画
            presentedViewController.dismiss(animated: false) {
                [unowned self] in dismissPresentedViewControllerIfNeeded()
            }
        } else {
            /// 如果presentedViewController为空,则dismiss自己 | 带动画
            dismiss(animated: true, completion: completion)
        }
    }
    
    
    /// 获取目标导航控制器
    /// - Parameter navigationType: 导航控制器类型
    /// - Returns: 目标导航控制器
    func targetNavigation<T>(_ navigationType: T.Type) -> T? where T: UINavigationController {
        if let tab = self as? UITabBarController {
            func matches(controller: UIViewController) -> Bool {
                controller.isMember(of: navigationType)
            }
            return tab.viewControllers?.first(where: matches) as? T
        } else if let navi = self as? T {
            return navi
        } else {
            return navigationController as? T
        }
    }
    
    func push(_ controller: UIViewController, animated: Bool = true) {
        if let navi = self as? UINavigationController {
            navi.pushViewController(controller, animated: animated)
        } else {
            navigationController?.pushViewController(controller, animated: animated)
        }
    }
    
    func embedInNavigationController<NavigationController>(_ navigationControllerType: NavigationController.Type = UINavigationController.self as! NavigationController.Type) -> NavigationController where NavigationController: UINavigationController {
        NavigationController(rootViewController: self)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
extension UIViewController {
	
	private struct Preview: UIViewControllerRepresentable {
		
		let viewController: UIViewController

		func makeUIViewController(context: Context) -> UIViewController { viewController }

		func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
	}

	var preview: some View {
		Preview(viewController: self)
	}
}
#endif
