//
//  Reusable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

public protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    
    public static var reuseIdentifier: String {
        String(describing: self)
    }
    
    public static func registerTo(layout: UICollectionViewLayout) {
        layout.register(self, forDecorationViewOfKind: reuseIdentifier)
    }
}

extension UICollectionReusableView: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UITableViewCell: Reusable {}
