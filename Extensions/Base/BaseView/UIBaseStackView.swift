//
//  UIBaseStackView.swift
//  KnowLED
//
//  Created by Choi on 2023/7/20.
//

import UIKit

class UIBaseStackView: UIStackView, UIViewLifeCycle {

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init(coder: NSCoder) {
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
