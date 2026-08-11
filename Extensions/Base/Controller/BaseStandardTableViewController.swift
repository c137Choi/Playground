//
//  BaseStandardTableViewController.swift
//
//  Created by Choi on 2022/9/22.
//
//  带一个默认Cell类型的表格视图

import UIKit

class BaseStandardTableViewController<Cell: UITableViewCell>: BaseTableViewController {

    /// 规避 Swift 6.3.3 EarlyPerfInliner 处理合成 deinit 时的崩溃(swiftlang/swift#90150)
    /// 由于该类为泛型且非 final,无法使用 isolated deinit(@preconcurrency 限制)
    /// 改用 @MainActor deinit 与父类 BaseViewController 的 deinit 隔离保持一致
    @_optimize(none)
    @MainActor deinit {}

    override func configureTableView(_ tableView: UITableView) {
        super.configureTableView(tableView)
        Cell.registerTo(tableView)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cell.dequeueReusableCell(from: tableView, indexPath: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: Cell, at indexPath: IndexPath) {}
    
}
