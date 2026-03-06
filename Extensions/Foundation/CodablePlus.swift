//
//  CodablePlus.swift
//
//  Created by Choi on 2022/8/13.
//

import Foundation

/// UnkeyedDecodingContainer跳过解码失败条目会用到
public struct VoidCodable: Codable {
    public func encode(to encoder: Encoder) throws {}
    public init(from decoder: Decoder) throws {
        _ = try decoder.singleValueContainer()
    }
}

// MARK: - 给无法解析的枚举一个默认值
protocol CodableEnumeration: RawRepresentable, Codable where RawValue: Codable {
    static var defaultCase: Self { get }
}

extension CodableEnumeration {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let decoded = try container.decode(RawValue.self)
            self = Self.init(rawValue: decoded) ?? Self.defaultCase
        } catch {
            self = Self.defaultCase
        }
    }
}
