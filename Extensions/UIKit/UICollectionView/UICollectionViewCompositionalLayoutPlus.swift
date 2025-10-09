//
//  UICollectionViewCompositionalLayoutPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/1/18.
//

import UIKit

extension NSCollectionLayoutDimension {
    static let fullWidth = NSCollectionLayoutDimension.fractionalWidth(1.0)
    static let fullHeight = NSCollectionLayoutDimension.fractionalHeight(1.0)
}


extension NSCollectionLayoutSize {
    static let fullSize = NSCollectionLayoutSize(widthDimension: .fullWidth, heightDimension: .fullHeight)
}
