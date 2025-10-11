//
//  SelfReflection.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

protocol SelfReflection {
    var itself: Self { get }
}

extension SelfReflection {
    var itself: Self { self }
}

extension Bool: SelfReflection {}
extension Optional: SelfReflection {}
extension Array: SelfReflection {}
