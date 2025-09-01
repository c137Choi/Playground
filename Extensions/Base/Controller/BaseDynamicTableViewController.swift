//
//  BaseDynamicTableViewController.swift
//
//  Created by Choi on 2022/8/18.
//

import UIKit

class BaseDynamicTableViewController
<PrimaryCell: UITableViewCell, ViewModel: PagableViewModelType>: BaseTableViewController, PagableViewModelDelegate, ViewModelHost {
    
    lazy var viewModel = ViewModel(delegate: self)
    
    override func initialConfigure() {
        super.initialConfigure()
        
        configureViewModel()
    }
    
    func configureViewModel() {
        viewModel.delegate = self
    }
    
    override func prepareTargets() {
        super.prepareTargets()
        
        viewModel.fetchMoreData()
    }
    
    override func configureTableView(_ tableView: UITableView) {
        super.configureTableView(tableView)
        PrimaryCell.registerTo(tableView)
    }
    
    func configureCell(_ cell: PrimaryCell, at indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PrimaryCell.dequeueReusableCell(from: tableView, indexPath: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    // MARK: - PagableViewModelDelegate
    func sectionsUpdated(_ indexSet: IndexSet?) {
        tableView.reloadData()
        tableView.backgroundView?.isHidden = viewModel.numberOfItems > 0
    }
    func itemsUpdated(_ indexPaths: [IndexPath]?) {
        tableView.reloadData()
        tableView.backgroundView?.isHidden = viewModel.numberOfItems > 0
    }
}
