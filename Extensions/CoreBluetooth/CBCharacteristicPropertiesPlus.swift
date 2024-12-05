//
//  CBCharacteristicPropertiesPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/11/4.
//

import CoreBluetooth

extension CBCharacteristicProperties: @retroactive CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var abilities: [String] = []
        if contains(.broadcast) {
            abilities.append("广播")
        }
        if contains(.read) {
            abilities.append("读")
        }
        if contains(.writeWithoutResponse) {
            abilities.append("写(无响应)")
        }
        if contains(.write) {
            abilities.append("写")
        }
        if contains(.notify) {
            abilities.append("通知")
        }
        if contains(.indicate) {
            abilities.append("indicate")
        }
        if contains(.authenticatedSignedWrites) {
            abilities.append("authenticatedSignedWrites")
        }
        if contains(.extendedProperties) {
            abilities.append("extendedProperties")
        }
        if contains(.notifyEncryptionRequired) {
            abilities.append("notifyEncryptionRequired")
        }
        if contains(.indicateEncryptionRequired) {
            abilities.append("indicateEncryptionRequired")
        }
        return "可\(abilities.joined(separator: ","))"
    }
}
