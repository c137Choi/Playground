//
//  LocalePlus.swift
//
//  Created by Choi on 2022/12/9.
//

import Foundation

extension Locale {
    
    /// 优先使用的Locale
    static var preferredLocale: Locale {
        if #available(iOS 26, *) {
            Locale.preferredLocales.first ?? Locale.current
        } else {
            Locale.preferredLanguages.first.map(Locale.init) ?? Locale.current
        }
    }
    
    var compatibleLanguageCode: String? {
        if #available(iOS 16, *) {
            language.languageCode.map(\.identifier)
        } else {
            languageCode
        }
    }
    
    var compatibleScriptCode: String? {
        if #available(iOS 16, *) {
            language.script.map(\.identifier)
        } else {
            scriptCode
        }
    }
}

func localized(
    _ localized: String.LocalizationValue,
    table: String? = nil,
    locale: Locale = .preferredLocale,
    comment: StaticString? = nil) -> String
{
    if #available(iOS 16.0, *) {
        /// 创建LocalizedStringResource
        var stringResource = LocalizedStringResource(localized, table: table, locale: locale, comment: comment)
        /// 生成本地化字符串
        let localizedString = String(localized: stringResource)
        /// 如果字符串为空, 使用英语本地化字符串作为返回值
        if localizedString.isEmpty {
            stringResource.locale = .english
            return String(localized: stringResource)
        } else {
            return localizedString
        }
    } else {
        /// 生成本地化字符串
        let localizedString = String(localized: localized, table: table, locale: locale, comment: comment)
        /// 如果字符串为空, 使用英语本地化字符串作为返回值
        if localizedString.isEmpty {
            return String(localized: localized, table: table, locale: .english, comment: comment)
        } else {
            return localizedString
        }
    }
}

// MARK: - 一些Locale常量
extension Locale {
    
    /// 简体中文
    static let chineseSimplified = if #available(iOS 16, *) {
        Locale(languageCode: .chinese, script: .hanSimplified)
    } else {
        Locale(identifier: "zh-Hans")
    }
    
    /// 繁体中文
    static let chineseTraditional = if #available(iOS 16, *) {
        Locale(languageCode: .chinese, script: .hanTraditional)
    } else {
        Locale(identifier: "zh-Hant")
    }
    
    /// 英语
    static let english = if #available(iOS 16, *) {
        Locale(languageCode: .english)
    } else {
        Locale(identifier: "en")
    }
}
