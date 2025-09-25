//
//  UIBaseCollectionReusableView.swift
//
//  Created by Choi on 2023/5/22.
//

import UIKit

class UIBaseCollectionReusableView: UICollectionReusableView, UIViewLifeCycle {

    @Published var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    func prepare() {
        prepareSubviews()
        prepareConstraints()
    }
    
    func prepareSubviews() {}
    
    func prepareConstraints() {}
}
