//
//  PointerAccessable.swift
//  KnowLED
//
//  Created by Choi on 2025/12/31.
//

import Foundation

protocol PointerAccessable: AnyObject {
    var pointer: UnsafeMutableRawPointer { get }
}

extension PointerAccessable {
    var pointer: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }
}

extension NSObject: PointerAccessable {}
extension UniqueAddress: PointerAccessable {}
