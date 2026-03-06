//
//  UnkeyedDecodingContainerPlus.swift
//  KnowLED
//
//  Created by Choi on 2026/3/6.
//

import Foundation

extension UnkeyedDecodingContainer {
    
    /// 封装「解码+跳过无效条目」逻辑
    mutating func compactDecode<T: Decodable>(_ type: T.Type) -> [T] {
        var elements: [T] = []
        while !isAtEnd {
            do {
                let element = try decode(T.self)
                elements.append(element)
            } catch {
                _ = try? decode(VoidCodable.self)
            }
        }
        return elements
    }
}
