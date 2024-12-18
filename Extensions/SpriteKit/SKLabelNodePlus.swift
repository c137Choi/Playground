//
//  SKLabelNodePlus.swift
//
//  Created by Choi on 2023/8/30.
//

import UIKit
import SpriteKit

extension SKLabelNode {
    
    /// SKLabelNode | 内部使用init(attributedText:)方法初始化
    convenience init(text: String, textColor: UIColor = .white, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular) {
        var attributes = [NSAttributedString.Key: Any].empty
        attributes[.font] = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        attributes[.foregroundColor] = textColor
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        self.init(attributedText: attributedText)
    }
    
    /// 更新attributedText
    func updateAttributedText(_ text: String, textColor: UIColor, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular) {
        var attributes = [NSAttributedString.Key: Any].empty
        attributes[.font] = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        attributes[.foregroundColor] = textColor
        
        attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func updateAttributedTextColor(_ textColor: UIColor) {
        guard let currentAttributedText = attributedText else { return }
        var attributes = currentAttributedText.attributes(at: 0, effectiveRange: nil)
        guard attributes[.foregroundColor].isValid else { return }
        attributes[.foregroundColor] = textColor
        
        attributedText = NSAttributedString(string: currentAttributedText.string, attributes: attributes)
    }
}
