//
//  ObserverTypePlus.swift
//  KnowLED
//
//  Created by Choi on 2026/5/14.
//

import RxSwift

extension ObserverType {
    
    func onNextOptional(_ element: Element?) {
        guard let element else { return }
        onNext(element)
    }
}
