//
//  SetClosureParameterAsSelfType.swift
//  KnowLED
//
//  Created by Choi on 2024/11/14.
//

import UIKit

// MARK: - 将自身类型作为参数传给Closure
fileprivate protocol UITableViewType {
    associatedtype TableView: UITableView = Self
    func performReloadWhileKeepPreviousLocation(reloadOperations: (TableView) -> Void)
}

fileprivate extension UITableViewType where Self: UITableView {
    
    func performReloadWhileKeepPreviousLocation(reloadOperations: (Self) -> Void) {
        /// 这里你可以使用UITableView的任意属性
        _ = self.contentOffset
        /// 或者将自身传入Closure | 同时子类亦可调用此方法, 并传回子类的类型
        reloadOperations(self)
    }
}

extension UITableView: UITableViewType {}

fileprivate class SubTableView: UITableView {}

fileprivate func testUITableViewType() {
    let sub = SubTableView(frame: .zero)
    sub.performReloadWhileKeepPreviousLocation { subTableView in
        
    }
}
