//
//  UITableViewHeaderFooterViewPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/6/9.
//

import UIKit

extension UITableViewHeaderFooterView {
    
    enum Associated {
        @UniqueAddress static var tableView
    }
    
    var tableView: UITableView? {
        get {
            tableView(UITableView.self)
        }
        set {
            setAssociatedObject(self, Associated.tableView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func tableView<T>(_ type: T.Type) -> T? where T: UITableView {
        if let existingTableView = associated(T.self, self, Associated.tableView) {
            return existingTableView
        }
        let fetchTableView = superview(type)
        setAssociatedObject(self, Associated.tableView, fetchTableView, .OBJC_ASSOCIATION_ASSIGN)
        return fetchTableView
    }
}

extension UITableViewHeaderFooterView {
    static func registerTo(_ tableView: UITableView) {
        tableView.register(self, forHeaderFooterViewReuseIdentifier: className)
    }
    static func dequeueReusableHeaderFooterView(from tableView: UITableView) -> Self? {
        tableView.dequeueReusableHeaderFooterView(withIdentifier: className) as? Self
    }
}
