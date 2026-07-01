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

nonisolated extension SelfReflection {
    var itself: Self { self }
}

nonisolated extension Bool: SelfReflection {}
nonisolated extension Optional: SelfReflection {}
nonisolated extension Array: SelfReflection {}
