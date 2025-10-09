//
//  UICollectionReusableViewPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/6/9.
//

import UIKit

extension UICollectionViewCell {
    
    static func registerTo(_ collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: className)
    }
    
    static func dequeueReusableCell(from collectionView: UICollectionView, indexPath: IndexPath) -> Self {
        collectionView.dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as! Self
    }
}

extension UICollectionReusableView {
    
    enum SupplementaryViewKind {
        case header
        case footer
        case custom(String)
        
        init(rawValue: String) {
            if rawValue == UICollectionView.elementKindSectionHeader {
                self = .header
            } else if rawValue == UICollectionView.elementKindSectionFooter {
                self = .footer
            } else {
                self = .custom(rawValue)
            }
        }
        
        var raw: String {
            switch self {
            case .header: return UICollectionView.elementKindSectionHeader
            case .footer: return UICollectionView.elementKindSectionFooter
            case .custom(let kind): return kind
            }
        }
    }
    
    enum Associated {
        @UniqueAddress static var collectionView
    }
    
    static func registerTo(layout: UICollectionViewLayout) {
        layout.register(self, forDecorationViewOfKind: className)
    }
    
    static func registerTo(_ collectionView: UICollectionView, kind: SupplementaryViewKind) {
        collectionView.register(self, forSupplementaryViewOfKind: kind.raw, withReuseIdentifier: className)
    }
    
    static func dequeReusableSupplementaryView(from collectionView: UICollectionView, kind: SupplementaryViewKind, indexPath: IndexPath) -> Self {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind.raw, withReuseIdentifier: className, for: indexPath) as! Self
    }
    
    var inferredIndexPath: IndexPath? {
        collectionView?.indexPath(forSupplementaryView: self)
    }
    
    var collectionView: UICollectionView? {
        get {
            collectionView(UICollectionView.self)
        }
        set {
            setAssociatedObject(self, Associated.collectionView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func collectionView<T>(_ type: T.Type) -> T? where T: UICollectionView {
        if let existingCollectionView = associated(T.self, self, Associated.collectionView) {
            return existingCollectionView
        } else {
            /// 获取父视图
            let fetchCollectionView = superview(type)
            /// 调用上面collectionView的setter方法设置CollectionView
            self.collectionView = fetchCollectionView
            /// 返回获取到的CollectionView
            return fetchCollectionView
        }
    }
}
