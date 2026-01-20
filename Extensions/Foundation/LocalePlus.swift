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

func localized(
    _ localizationValue: String.LocalizationValue,
    table: String? = nil,
    locale: Locale = AppLanguage.language.locale,
    comment: StaticString? = nil) -> String
{
    /// 中文Bundle
    lazy var zhHansBundle = Bundle.main.path(forResource: "zh-Hans", ofType: "lproj").flatMap {
        Bundle(path: $0)
    }
    
    /// 英文Bundle
    lazy var enBundle = Bundle.main.path(forResource: "en", ofType: "lproj").flatMap {
        Bundle(path: $0)
    }
    
    /// 中文翻译
    lazy var chineseTranslation = if #available(iOS 16, *) {
        zhHansBundle.map(fallback: "N/A") { bundle in
            let bundleDescription = LocalizedStringResource.BundleDescription.atURL(bundle.bundleURL)
            return LocalizedStringResource(localizationValue, table: table, locale: .chineseSimplified, bundle: bundleDescription, comment: comment).transform {
                String(localized: $0)
            }
        }
    } else {
        zhHansBundle.flatMap(fallback: "N/A") { bundle in
            String(localized: localizationValue, table: table, bundle: bundle, locale: .chineseSimplified, comment: comment)
        }
    }
    
    /// 英文翻译
    lazy var englishTranslation = if #available(iOS 16, *) {
        enBundle.map(fallback: "N/A") {
            let bundleDescription = LocalizedStringResource.BundleDescription.atURL($0.bundleURL)
            return LocalizedStringResource(localizationValue, table: table, locale: .english, bundle: bundleDescription, comment: comment).transform {
                String(localized: $0)
            }
        }
    } else {
        enBundle.flatMap(fallback: "N/A") {
            String(localized: localizationValue, table: table, bundle: $0, locale: .english, comment: comment)
        }
    }
    
    if #available(iOS 16, *) {
        /// 创建LocalizedStringResource
        let stringResource = LocalizedStringResource(localizationValue, table: table, locale: locale, comment: comment)
        /// 生成本地化字符串
        let localizedString = String(localized: stringResource)
        /// 未发现翻译文本时, 默认使用英语翻译
        if locale != .chineseSimplified, localizedString == chineseTranslation {
            return englishTranslation
        }
        return localizedString
    } else {
        /// 生成本地化字符串
        let localizedString = String(localized: localizationValue, table: table, locale: locale, comment: comment)
        /// 未发现翻译文本时, 默认使用英语翻译
        if locale != .chineseSimplified, localizedString == chineseTranslation {
            return englishTranslation
        }
        return localizedString
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
