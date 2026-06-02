//
//  Constants.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/20.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

enum Size {
	
    /// 屏幕尺寸
    /// - Parameter isLandscape: 是否横屏
    /// - Returns: 横屏/竖屏的屏幕尺寸
    static func screenSize(isLandscape: Bool) -> CGSize {
        isLandscape ? screenSize.landscape : screenSize.portrait
    }
    
	static let commonSafeAreaInsets = UIApplication.keyWindow?.safeAreaInsets ?? .zero
	
	static let screenScale = UIScreen.main.scale
	
    static var screenHeight: CGFloat { screenSize.height }
	
    static var screenWidth: CGFloat { screenSize.width }
	
    static var screenSize: CGSize { UIScreen.main.bounds.size }
}
