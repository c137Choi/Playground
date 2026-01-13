//
//  LocalePlus.swift
//
//  Created by Choi on 2022/12/9.
//

import Foundation

extension Locale {
    static var application = Locale.current
    
    static let chineseSimplified = Locale(identifier: "zh_CN")
    static let chineseTraditional = Locale(identifier: "zh-Hant_CN")
    static let enUS = Locale(identifier: "en_US")
}

func localized(
    _ localized: String.LocalizationValue,
    table: String? = nil,
    locale: Locale = .application,
    comment: StaticString? = nil) -> String
{
    if #available(iOS 16.0, *) {
        let resource = LocalizedStringResource(localized, table: table, locale: locale, comment: comment)
        return String(localized: resource)
    } else {
        return String(localized: localized, table: table, locale: locale, comment: comment)
    }
}
