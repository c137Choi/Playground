//
//  CurrentValueSubject.swift
//  KnowLED
//
//  Created by Choi on 2026/6/30.
//

import Combine

nonisolated extension CurrentValueSubject {
    
    static func << (lhs: CurrentValueSubject<Output, Failure>, rhs: Output) {
        lhs.send(rhs)
    }
}
