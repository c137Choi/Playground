//
//  BaseStandardViewController.swift
//
//  Created by Choi on 2022/8/18.
//

import UIKit

class BaseStandardViewController<MainView: ViewModelSetupView>: BaseViewController, ViewModelHost {
    
    lazy var mainView = initializeMainView()
    
    lazy var viewModel = MainView.ViewModel()
    
    override var defaultMainView: UIView? {
        mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 尝试转换成MainView -> 如果转换成功说明MainView被实例化,继续执行if语句中的逻辑
        if defaultMainView.as(MainView.self).isValid {
            mainView.setupViewModel(viewModel)
        }
    }
    
    /// Override point
    /// 子类可重写此方法使用自己定义的主视图初始化方法创建主视图
    /// 例如: BaseControllerView需要使用init(controller: ViewController)方法创建主视图
    func initializeMainView() -> MainView {
        MainView()
    }
}
