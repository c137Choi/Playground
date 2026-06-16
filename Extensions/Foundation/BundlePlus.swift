//
//  BundlePlus.swift
//
//  Created by Choi on 2022/9/2.
//

import UIKit

nonisolated extension Bundle {
    
    /// 应用图标Image对象
    var appIcon: UIImage? {
        infoDictionary.flatMap { info in
            guard let icons = info["CFBundleIcons"] as? [String: Any] else { return nil }
            guard let primary = icons["CFBundlePrimaryIcon"] as? [String: Any] else { return nil }
            guard let files = primary["CFBundleIconFiles"] as? [String] else { return nil }
            guard let iconName = files.last else { return nil }
            return UIImage(named: iconName)
        }
    }
    
    /// 显示名称
    var displayName: String? {
        infoDictionary.flatMap { $0["CFBundleDisplayName"] as? String }
    }
    
    /// 版本号(编译号)
    var versionWithBuild: String? {
        guard let version, let build else { return nil }
        return "\(version)(\(build))"
    }
    
    /// 返回版本号
    var version: String? {
        infoDictionary.flatMap { $0["CFBundleShortVersionString"] as? String }
    }
    
    /// 返回build号
    var build: String? {
        infoDictionary.flatMap { $0["CFBundleVersion"] as? String }
    }
}
