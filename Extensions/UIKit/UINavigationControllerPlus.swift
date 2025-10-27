//
//  UINavigationControllerPlus.swift
//
//  Created by Choi on 2022/9/1.
//

import UIKit

extension UINavigationController {
    
    convenience init(@ArrayBuilder<UIViewController> _ controllersBuilder: () -> [UIViewController]) {
        self.init()
        setViewControllers(controllersBuilder(), animated: false)
    }
    
    /// 新控制器压栈 | 移除所有以前的控制器
    /// - Parameters:
    ///   - newRootController: 新的根控制器
    func refillNavigationStack(_ newRootController: UIViewController, animated: Bool = true) {
        setViewControllers([newRootController], animated: animated)
    }
    
    /// 替换顶层控制器
    /// - Parameters:
    ///   - newController: 顶层控制器
    func replaceTopViewController(_ newController: UIViewController, animated: Bool = true) {
        var tempControllers = viewControllers
        if tempControllers.first.isValid {
            tempControllers.removeFirst()
        }
        tempControllers.insert(newController, at: 0)
        setViewControllers(tempControllers, animated: animated)
    }
    
    /// 退到指定类型的控制器
    /// - Parameters:
    ///   - classType: 控制器类
    ///   - animated: 是否动画执行
    func popToViewControllerTyped(_ classType: AnyClass, animated: Bool) {
        let targetController = viewControllers.first { controller in
            controller.isMember(of: classType)
        }
        if let targetController {
            popToViewController(targetController, animated: animated)
        }
    }
}
