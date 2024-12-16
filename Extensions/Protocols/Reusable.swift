//
//  Reusable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import UIKit

public protocol Reusable {
    static var reuseIdentifier: String { get }
}
public protocol ReusableObject: Reusable, AnyObject {
    
}
extension UICollectionReusableView: ReusableObject {}
extension UITableViewHeaderFooterView: ReusableObject {}
extension UITableViewCell: ReusableObject {}
extension ReusableObject {
    
    public static var reuseIdentifier: String {
        String(describing: self)
    }
    
    public static func registerTo(layout: UICollectionViewLayout) {
        layout.register(self, forDecorationViewOfKind: reuseIdentifier)
    }
}
