//
//  UIBaseCollectionViewCell.swift
//
//  Created by Choi on 2022/9/19.
//

import UIKit

class UIBaseCollectionViewCell: UICollectionViewCell, UIViewLifeCycle {
    
    /// 直接复写Cell的backgroundColor属性会有循环调用问题
    /// 所以重新定义一个背景色属性
    var defaultBackgroundColor: UIColor? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    var defaultSelectedBackgroundColor: UIColor? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    var defaultHighlightedBackgroundColor: UIColor? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    @Published var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        var background: UIBackgroundConfiguration = .listPlainCell()
        if let defaultSelectedBackgroundColor, state.isSelected {
            background.backgroundColor = defaultSelectedBackgroundColor
        } else if let defaultHighlightedBackgroundColor, state.isHighlighted {
            background.backgroundColor = defaultHighlightedBackgroundColor
        } else {
            if let defaultBackgroundColor {
                background.backgroundColor = defaultBackgroundColor
            } else {
                background = .clear()
            }
        }
        
        backgroundConfiguration = background
    }
    
    func prepare() {
        defaultBackgroundColor = .clear
        prepareSubviews()
        prepareConstraints()
    }
    
    func prepareSubviews() {}
    
    func prepareConstraints() {}
    
}
