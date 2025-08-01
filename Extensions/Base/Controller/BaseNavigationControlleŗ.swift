//
//  BaseNavigationController.swift
//
//  Created by Choi on 2022/8/25.
//

import UIKit
import QMUIKit

class BaseNavigationController: UINavigationController, PresentedControllerType {
    
    var animator: JellyAnimator?
    
    var allowedInterfaceOrientations = UIInterfaceOrientationMask.all {
        didSet {
            qmui_setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        initialSetup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialSetup()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialSetup() {
        
    }
    
    /// 让最顶部的控制器决定状态栏的样式
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        allowedInterfaceOrientations
    }
}
