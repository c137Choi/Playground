//
//  DateFormatterPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/11/26.
//  Copyright © 2021 Choi. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /// 共享实例
    fileprivate static let instance = DateFormatter()
    
    /// 使用前先重置
    static var shared: DateFormatter {
        instance.reset
    }
	
    fileprivate var reset: DateFormatter {
		formattingContext = .unknown
		dateFormat = ""
		dateStyle = .full
		timeStyle = .none
		locale = .chineseSimplified
		generatesCalendarDates = false
		timeZone = .current
		calendar = .current
		isLenient = false
		doesRelativeDateFormatting = false
		defaultDate = nil
		formatterBehavior = .behavior10_4
		return self
	}
}
