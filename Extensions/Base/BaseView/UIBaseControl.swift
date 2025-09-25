//
//  UIBaseControl.swift
//
//  Created by Choi on 2022/8/27.
//

import UIKit

class UIBaseControl: UIControl, UIViewLifeCycle {
    
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
