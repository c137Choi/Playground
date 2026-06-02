//
//  PlistDocument.swift
//
//  Created by Choi on 2022/9/30.
//

import UIKit

final class PlistDocument: UIDocument {
    var data: Any?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        data = contents
        try super.load(fromContents: contents, ofType: typeName)
        self.open { completed in
            dprint("打开\(completed ? "成功" : "失败")")
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        guard let data else {
            return try Data(contentsOf: fileURL)
        }
        return data
    }
    
    
    func syncToiCloud(identifier: String?, _ completed: @escaping (Bool) -> Void) {
        let fileName = fileURL.lastPathComponent
        guard let iCloud = URL.ubiquityContainer(identifier: identifier) else {
            completed(false)
            return
        }
        
        guard let data = try? Data(contentsOf: fileURL) else {
            completed(false)
            return
        }
        self.data = data
        
        let remoteFilePath = iCloud.appendingPathComponent(fileName)
        dprint("远程文件名", remoteFilePath)
        if FileManager.default.fileExists(atPath: remoteFilePath.absoluteString) {
            dprint("文件已存在,覆盖原有文件")
            save(to: remoteFilePath, for: .forOverwriting, completionHandler: completed)
        } else {
            dprint("文件不存在,创建文件")
            save(to: remoteFilePath, for: .forCreating, completionHandler: completed)
        }
    }
}

extension URL {
    
    var plist: PlistDocument {
        PlistDocument(fileURL: self)
    }
}
