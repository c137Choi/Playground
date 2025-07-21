//
//  UIControlTarget.swift
//  KnowLED
//
//  Created by Choi on 2025/7/21.
//

import UIKit

public final class UIControlTarget<T> where T: AnyObject {
    /// 标识符
    let identifier: UIAction.Identifier
    /// 回调Closure
    let handler: (T) -> Void
    /// 初始化
    init(_ handler: @escaping (T) -> Void) {
        self.handler = handler
        self.identifier = UIAction.Identifier(String.randomUUID)
    }
    
    /// 触发方法
    @objc func trigger(_ sender: AnyObject) {
        guard let uiControl = sender as? T else { return }
        handler(uiControl)
    }
}
