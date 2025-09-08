//
//  SelfReflectable.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

protocol SelfReflectable {
    var itself: Self { get }
}

extension SelfReflectable {
    var itself: Self { self }
}

extension Bool: SelfReflectable {}
extension Optional: SelfReflectable {}
extension Array: SelfReflectable {}
