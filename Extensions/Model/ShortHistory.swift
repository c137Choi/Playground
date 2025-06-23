//
//  Untitled.swift
//  KnowLED
//
//  Created by Choi on 2025/6/17.
//

import Foundation

struct ShortHistory<T>: Configurable {
    var last: T?
    var latest: T
}
