//
//  LocalePlus.swift
//
//  Created by Choi on 2022/12/9.
//

import Foundation

extension Locale {
    
    /// 系统列表中列出的语言选项
    static var compatiblePreferredLocales: [Locale] {
        if #available(iOS 26, *) {
            Locale.preferredLocales
        } else {
            Locale.preferredLanguages.map(Locale.init)
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
    
    /// Locale(languageCode: .chinese, script: .hanSimplified) -> 简体中文
    /// Locale(languageCode: .chinese, script: .hanTraditional) -> 繁體中文
    /// Locale(languageCode: .english) -> English
    /// Locale(languageCode: .spanish) -> Español
    /// Locale(languageCode: .japanese) -> 日本語
    /// Locale(languageCode: .korean) -> 한국어
    /// Locale(languageCode: .french) -> Français
    /// Locale(languageCode: .german) -> Deutsch
    /// Locale(languageCode: .italian) -> Italiano
    /// Locale转成对应的语言名称
    var languageName: String? {
        localizedString(forIdentifier: identifier).map {
            $0.capitalized(with: self)
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
    
    /// 英语
    static let english = if #available(iOS 16, *) {
        Locale(languageCode: .english)
    } else {
        Locale(identifier: "en")
    }
}
