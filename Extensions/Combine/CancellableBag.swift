//
//  CancellableBag.swift
//  KnowLED
//
//  Created by Choi on 2025/2/5.
//

import Combine

public final class CancellableBag {
    
    fileprivate(set) var cancellables: Set<AnyCancellable>
    
    public init() {
        cancellables = []
    }
    
    public func cancel() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        cancellables = []
    }
}

extension CancellableBag {
    
    public func insert(@ArrayBuilder<AnyCancellable> _ builder: () -> [AnyCancellable]) {
        let cancellables = builder()
        insert(cancellables)
    }
    
    public func insert(_ cancellables: AnyCancellable...) {
        insert(cancellables)
    }
    
    public func insert(_ cancellables: [AnyCancellable]) {
        cancellables.forEach { cancellable in
            cancellable.store(in: self)
        }
    }
}

extension AnyCancellable {
    
    public func store(in bag: CancellableBag) {
        store(in: &bag.cancellables)
    }
}
