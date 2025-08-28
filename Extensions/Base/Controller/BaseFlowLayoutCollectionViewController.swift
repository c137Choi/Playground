//
//  BaseFlowLayoutCollectionViewController.swift
//
//  Created by Choi on 2023/2/16.
//

import UIKit

class BaseFlowLayoutCollectionViewController<
FlowLayout: UICollectionViewFlowLayout,
Cell: UICollectionViewCell,
Header: UICollectionReusableView,
Footer: UICollectionReusableView>: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {

    lazy var flowLayout = makeFlowLayout()
    
    override var defaultLayout: UICollectionViewLayout {
        flowLayout
    }
    
    var numberOfColumns: Int {
        2
    }
    
    var cellHeight: CGFloat {
        50.0
    }
    
    override func makeEmptyView() -> UIView {
        TableViewEmptyView()
    }
    
    override func configureCollectionView(_ collectionView: UICollectionView) {
        super.configureCollectionView(collectionView)
        Cell.registerTo(collectionView)
        Header.registerTo(collectionView, kind: .header)
        Footer.registerTo(collectionView, kind: .footer)
    }
    
    func configureFlowLayout(_ flowLayout: FlowLayout) {}
    
    func makeFlowLayout() -> FlowLayout {
        let layout = FlowLayout()
        configureFlowLayout(layout)
        return layout
    }
    
    func configureCell(_ cell: Cell, at indexPath: IndexPath) { }
    
    func configureHeader(_ header: Header, at indexPath: IndexPath) { }
    
    func configureFooter(_ footer: Footer, at indexPath: IndexPath) { }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// 列数
        var columnCount = max(numberOfColumns.cgFloat, 1.0)
        /// Item高度
        var cellHeight = cellHeight
        /// 如果设定了优先的尺寸, 则根据设置的尺寸设定列数和Item高度
        if let preferredCellSize {
            columnCount = collectionView.bounds.width / preferredCellSize.width
            columnCount = columnCount.double.rounded(.toNearestOrEven).cgFloat
            cellHeight = preferredCellSize.height
        }
        /// 分组边距占掉的宽度
        let sectionInsetWidth = flowLayout.sectionInsetsAt(indexPath).horizontal
        /// Item间隔占用的宽度
        let columnSpaces = (columnCount - 1.0) * flowLayout.minimumInteritemSpacingForSectionAt(indexPath)
        /// 横向所有Item占用的总宽度
        let itemsWidth = collectionView.bounds.width - sectionInsetWidth - columnSpaces
        /// 每个Item的宽度 | 用floor方法包裹运算结果，可防止某些情况下（如缩放Item时）Item间隙会变得不均匀的问题
        let itemWidth = floor(itemsWidth / columnCount)
        return CGSize(width: itemWidth, height: cellHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = Cell.dequeueReusableCell(from: collectionView, indexPath: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryViewKind = UICollectionReusableView.SupplementaryViewKind(rawValue: kind)
        switch supplementaryViewKind {
        case .header:
            let header = Header.dequeReusableSupplementaryView(from: collectionView, kind: supplementaryViewKind, indexPath: indexPath)
            configureHeader(header, at: indexPath)
            return header
        case .footer:
            let footer = Footer.dequeReusableSupplementaryView(from: collectionView, kind: supplementaryViewKind, indexPath: indexPath)
            configureFooter(footer, at: indexPath)
            return footer
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let targetSize = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height)
        return headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at: indexPath)
        let targetSize = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height)
        return headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
