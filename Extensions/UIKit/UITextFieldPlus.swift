//
//  UITextFieldPlus.swift
//
//  Created by Choi on 2022/12/1.
//

import UIKit

extension UITextField {
    
    enum Associated {
        @UniqueAddress static var placeholderColor
    }
}

extension Choi where Base: UITextField {
    
    public var placeholderColor: UIColor? {
        
        get {
            associated(UIColor.self, self, UITextField.Associated.placeholderColor)
        }
        
        nonmutating set {
            guard let newValue else { return }
            setAssociatedObject(self, UITextField.Associated.placeholderColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: newValue,
                .font: base.font ?? .systemFont(ofSize: 12)
            ]
            base.attributedPlaceholder = NSMutableAttributedString(string: base.placeholder ?? "", attributes: attributes)
        }
    }
}
