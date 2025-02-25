//
//  StaticStringPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/2/25.
//

import Foundation

extension StaticString: @retroactive Equatable {
    
    /// 方案来源: https://gist.github.com/McNight/c3a2b2bc3f047b09a1d1f3b27f8fb223
    public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
        if lhs.hasPointerRepresentation && rhs.hasPointerRepresentation {
            return lhs.utf8Start == rhs.utf8Start ? true : strcmp(lhs.utf8Start, rhs.utf8Start) == 0
        }
        else if lhs.hasPointerRepresentation == false && rhs.hasPointerRepresentation == false {
            return lhs.unicodeScalar.value == rhs.unicodeScalar.value
        }
        else {
            return false
        }
    }
}
