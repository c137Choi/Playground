//
//  File.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/7/28.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

extension UIRectCorner: @retroactive CaseIterable {
	public static let allCases: [UIRectCorner] = [
		.topLeft, .topRight, .bottomLeft, .bottomRight
	]
}

extension CACornerMask {
    
    static var topLeft: CACornerMask {
        .layerMinXMinYCorner
    }
    
    static var topRight: CACornerMask {
        .layerMaxXMinYCorner
    }
    
    static var bottomLeft: CACornerMask {
        .layerMinXMaxYCorner
    }
    
    static var bottomRight: CACornerMask {
        .layerMaxXMaxYCorner
    }
    
	public static var allCorners: CACornerMask {
		[
			.layerMinXMinYCorner,
			.layerMaxXMinYCorner,
			.layerMinXMaxYCorner,
			.layerMaxXMaxYCorner
		]
	}
}

extension UIRectCorner {
	
	/// UIRectCorner 转换成 CACornerMask
	var caCornerMask: CACornerMask {
		Self.allCases
			.filter(contains)
			.map(\.rawValue)
			.map(CACornerMask.init)
			.reduce(CACornerMask()) { result, item in
				result.union(item)
			}
	}
}
