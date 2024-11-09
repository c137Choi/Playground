//
//  BaseStandardTableViewController.swift
//
//  Created by Choi on 2022/9/22.
//
//  带一个默认Cell类型的表格视图

import UIKit

class BaseStandardTableViewController<Cell: UITableViewCell>: BaseTableViewController {

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
