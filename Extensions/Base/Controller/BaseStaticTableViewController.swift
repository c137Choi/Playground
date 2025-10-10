//
//  BaseStaticTableViewController.swift
//
//  Created by Choi on 2022/8/11.
//

import UIKit

class BaseStaticTableViewController<StaticTable: UIBaseStaticTable>: BaseTableViewController {
    
    lazy var staticTable = StaticTable()
    
    override func makeTableView() -> UITableView {
        staticTable.setup { table in
            table.autoresizingMask = .autoResize
            table.backgroundColor = .baseBackground
        }
    }
}
