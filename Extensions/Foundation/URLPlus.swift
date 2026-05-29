//
//  URLPlus.swift
//
//  Created by Choi on 2022/8/17.
//

import Foundation

extension URL {
    
    static func ubiquityContainer(identifier: String?) -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: identifier)
    }
    
    nonisolated static var libraryDirectory: URL {
        guard let url = url(for: .libraryDirectory) else {
            fatalError("NOT OK")
        }
        return url
    }
    
    nonisolated static var documentDirectory: URL {
        if #available(iOS 16.0, *) {
            return URL.documentsDirectory
        } else {
            guard let url = url(for: .documentDirectory) else {
                fatalError("🤯")
            }
            return url
        }
    }
    
    nonisolated static func url(for path: FileManager.SearchPathDirectory) -> URL? {
        FileManager.default.urls(for: path, in: .userDomainMask).first
    }
    
    /// scheme为https或http的URL
    nonisolated var httpURL: URL? {
        switch scheme?.lowercased() {
        case "https", "http":
            return self
        default:
            return nil
        }
    }
}
