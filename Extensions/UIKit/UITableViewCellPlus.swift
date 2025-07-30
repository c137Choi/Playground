//
//  UITableViewCellPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/6/9.
//

import UIKit

extension UITableViewCell {
    
    enum Associated {
        @UniqueAddress static var tableView
        @UniqueAddress static var row
    }
    
    var inferredIndexPath: IndexPath? {
        tableView?.indexPath(for: self)
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

extension UITableViewCell {
    static func registerTo(_ tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }
    static func dequeueReusableCell(from tableView: UITableView, indexPath: IndexPath) -> Self {
        tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Self
    }
}
