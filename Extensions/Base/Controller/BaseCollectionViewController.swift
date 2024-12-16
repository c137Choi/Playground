//
//  BaseCollectionViewController.swift
//
//  Created by Choi on 2023/2/16.
//

import UIKit
import RxSwift

class BaseCollectionViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    lazy var collectionView = makeCollectionView(layout: defaultLayout)
    
    lazy var emptyView = makeEmptyView()
    
    var isLandscape: Bool? {
        didSet {
            defaultLayout.invalidateLayout()
        }
    }
    
    var preferredCellSize: CGSize? {
        nil
    }
    
    @available(iOS 13.0, *)
    var compositionalLayout: UICollectionViewCompositionalLayout? {
        nil
    }
    
    var defaultLayout: UICollectionViewLayout {
        UICollectionViewLayout()
    }
    
    /// 选中Cell之后是否立刻反选
    var deselectCellAfterCellSelection = true
    
    /// 是否开启双指滑动多选 | 只在必要的地方开启, 否则会导致进入多选状态之后无法点击cell进入下一级页面
    var isMultipleSelectionInteractionEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 配置Collection View
        configureCollectionView(collectionView)
        /// 添加Collection View
        addCollectionView(collectionView)
    }
    
    override func prepareTargets() {
        super.prepareTargets()
        
        let isLandscape = { isVisible in
            isVisible ? UIDevice.rx.isLandscape : .empty()
        }
        /// 使用isVisible + flatMapLatest监听屏幕方向改变
        /// 是因为view不在视图层级中时,布局更新会失败
        rx.isVisible.flatMapLatest(isLandscape)
            .delay(.milliseconds(50), scheduler: MainScheduler.instance)
            .startWith(UIDevice.current.orientation.isScreenLandscape)
            .removeDuplicates
            .bind(to: rx.isLandscape)
            .disposed(by: rx.disposeBag)
    }
    
    /// 添加Collection View
    /// 调用时机:viewDidLoad()
    func addCollectionView(_ collectionView: UICollectionView) {
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    /// 调用时机:viewDidLoad()
    func configureCollectionView(_ collectionView: UICollectionView) {
        collectionView.backgroundView = emptyView
        collectionView.delaysContentTouches = false
        collectionView.autoresizingMask = .autoResize
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = baseViewBackgroundColor
        if #available(iOS 13.0, *) {
            if let compositionalLayout {
                collectionView.setCollectionViewLayout(compositionalLayout, animated: false)
            }
        }
        /// 占位图默认隐藏
        emptyView.isHidden = true

        UICollectionViewCell.registerTo(collectionView)
        UICollectionReusableView.registerTo(collectionView, kind: .header)
        UICollectionReusableView.registerTo(collectionView, kind: .footer)
    }
    
    /// 调用时机:懒加载
    func makeCollectionView(layout: UICollectionViewLayout) -> UICollectionView {
        UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    /// 创建空视图
    func makeEmptyView() -> UIView {
        UIView()
    }
    // MARK: - CollectionView Delegates
    // 注意: 必须父类里有实现,代理方法才会调用
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        preferredCellSize ?? .zero
    }
    
    /// 选中条目
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if deselectCellAfterCellSelection {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - CollectionView Datasource
    
    /// 每组条目数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 0 }
    
    /// 分组数
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    /// 生成Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell.dequeueReusableCell(from: collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UICollectionReusableView.reuseIdentifier, for: indexPath)
    }
    
    /// 滑动多选代理方法
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        isMultipleSelectionInteractionEnabled
    }
    
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        
    }
    
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        false
    }
    
}
