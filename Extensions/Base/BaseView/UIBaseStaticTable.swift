//
//  UIBaseStaticTable.swift
//  KnowLED
//
//  Created by Choi on 2023/7/28.
//

import UIKit

typealias StaticSection = UIBaseStaticTable.Section
typealias StaticRow = UIBaseStaticTable.Row

class UIBaseStaticTable: UITableView, UIViewLifeCycle, UITableViewDelegate, UITableViewDataSource {
    
    class var style: UITableView.Style {
        .grouped
    }
    
    var deselectRowAfterSelection = true
    
    var sections: [StaticSection] = [] {
        didSet {
            reloadData()
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: Self.style)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    func prepare() {
        UITableViewHeaderFooterView.registerTo(self)
        delegate = self
        dataSource = self
        separatorColor = 0xEDEDED.uiColor
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        estimatedRowHeight = 40.0
        if #available(iOS 15, *) {
            sectionHeaderTopPadding = 0
        }
        prepareSubviews()
        prepareConstraints()
    }
    
    func prepareSubviews() {}
    
    func prepareConstraints() {}
    
    // MARK: - UITableViewDelegate
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        sections[section].headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// UITableView实例的rowHeight属性默认值为UITableView.automaticDimension(-1.0)
        /// 如果设置了正值, 则整个TableView使用固定Cell高度. 否则使用Row的高度
        if tableView.rowHeight > 0 {
            tableView.rowHeight
        } else {
            sections[indexPath.section].rows[indexPath.row].height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        sections[section].footerHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections.element(at: section).or(0) { staticSection in
            staticSection.tableView = tableView
            staticSection.sectionIndex = section
            return staticSection.rows.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UITableViewHeaderFooterView.dequeueReusableHeaderFooterView(from: tableView).unwrap { header in
            header.contentView.backgroundColor = tableView.backgroundColor
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        sections[indexPath.section].rows[indexPath.row].cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UITableViewHeaderFooterView.dequeueReusableHeaderFooterView(from: tableView).unwrap { footer in
            footer.contentView.backgroundColor = tableView.backgroundColor
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// 执行Cell回调
        sections[indexPath.section][indexPath.row].doSelect()
        if deselectRowAfterSelection {
            /// 执行反选
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension UIBaseStaticTable {
    
    final class Row: Configurable {
        
        /// 高度(默认值: UITableView.automaticDimension)
        var height: CGFloat
        /// 点击回调闭包
        fileprivate var didSelectCallback: SimpleCallback?
        /// 点击回调闭包数组
        fileprivate var didSelectCallbacks: [SimpleCallback] = []
        /// 核心Cell对象(弱引用)
        private weak var core: UITableViewCell?
        
        /// 初始化
        /// - Parameters:
        ///   - cell: Cell视图
        ///   - height: 指定高度
        init(cell: UITableViewCell, height: CGFloat = UITableView.automaticDimension) {
            self.core = cell
            self.height = height
        }
        
        /// 设置单个的选中回调方法
        /// - Parameter execute: 执行回调
        func didSelect(execute: @escaping SimpleCallback) {
            didSelectCallback = execute
        }
        
        /// 设置多个回调Closure
        /// - Parameter execute: 执行的Closure
        func appendDidSelect(execute: @escaping SimpleCallback) {
            didSelectCallbacks.append(execute)
        }
        
        /// 执行相关的回调方法
        func doSelect() {
            if let didSelectCallback {
                didSelectCallback()
            }
            didSelectCallbacks.forEach { closure in
                closure()
            }
        }
        
        var cell: UITableViewCell {
            core ?? UITableViewCell()
        }
    }
    
    final class Section {
        let headerHeight: CGFloat
        let footerHeight: CGFloat
        var rows: [StaticRow] {
            didSet {
                guard let tableView, let sectionIndex else { return }
                /// 方案1:
                UIView.performWithoutAnimation {
                    /// 根据UITableView.RowAnimation.none的注释来看
                    /// The inserted or deleted rows use the default animations.
                    /// 所以如果不使用动画,需要将下面一句放在UIView.performWithoutAnimation中执行
                    tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
                }
//                /// 方案2:
//                UIView.setAnimationsEnabled(false)
//                defer {
//                    UIView.setAnimationsEnabled(true)
//                }
//                tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
            }
        }
        var sectionIndex: Int?
        weak var tableView: UITableView?
        
        /// 初始化
        /// - Parameters:
        ///   - headerHeight: 组头高度
        ///   - footerHeight: 组尾高度
        ///   - rowsBuilder: 包含的Rows
        init(headerHeight: CGFloat = 0, footerHeight: CGFloat = 0, @ArrayBuilder<StaticRow> _ rowsBuilder: () -> [StaticRow]) {
            self.headerHeight = headerHeight
            self.footerHeight = footerHeight
            self.rows = rowsBuilder()
        }
        
        subscript(_ rowIndex: Int) -> StaticRow {
            rows[rowIndex]
        }
        
        func appendRows(@ArrayBuilder<StaticRow> _ rowsBuilder: () -> [StaticRow]) {
            let rows = rowsBuilder()
            self.rows.append(contentsOf: rows)
        }
    }
}

extension UIBaseStaticTable {
    
    func refillSections(@ArrayBuilder<Section> _ sectionsBuilder: () -> [StaticSection]) {
        sections.removeAll()
        appendSections(sectionsBuilder)
    }
    
    func appendSections(@ArrayBuilder<Section> _ sectionsBuilder: () -> [StaticSection]) {
        let result = sectionsBuilder()
        sections.append(contentsOf: result)
    }
    
    var rowsCount: Int {
        sections.reduce(0) { partialResult, section in
            partialResult + section.rows.count
        }
    }
    
    subscript(_ section: Int) -> StaticSection {
        sections[section]
    }
}

// MARK: - 相关扩展
extension UITableViewCell {
    
    var row: StaticRow {
        row(height: UITableView.automaticDimension)
    }
    
    func row(height: CGFloat) -> StaticRow {
        if let row = associated(StaticRow.self, self, Associated.row) {
            return row.with(new: \.height, height)
        } else {
            let row = StaticRow(cell: self, height: height)
            setAssociatedObject(self, Associated.row, row, .OBJC_ASSOCIATION_RETAIN)
            return row
        }
    }
}
