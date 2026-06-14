//
//  CancellableBag.swift
//  KnowLED
//
//  Created by Choi on 2025/2/5.
//

import Combine

public final class CancellableBag {
    
    fileprivate(set) var cancellables = Set<AnyCancellable>.empty
    
    public func cancelAll() {
        defer {
            cancellables = []
        }
        for element in cancellables {
            element.cancel()
        }
    }
    
    deinit {
        cancelAll()
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
