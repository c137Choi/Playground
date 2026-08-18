//
//  ObserverTypePlus.swift
//  KnowLED
//
//  Created by Choi on 2026/5/14.
//

import RxSwift

nonisolated extension ObserverType {
    
    static func << (lhs: Self, rhs: Element) {
        lhs.onNext(rhs)
    }
    
    func onNextOptional(_ element: Element?) {
        guard let element else { return }
        onNext(element)
    }
}
