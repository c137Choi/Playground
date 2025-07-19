//
//  DisposeBagPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/19.
//

import RxSwift

extension DisposeBag {
    
    static var empty: DisposeBag {
        DisposeBag()
    }
    
    func insert(@ArrayBuilder<Disposable> builder: () -> [Disposable]) {
        let disposables = builder()
        insert(disposables)
    }
    
    public convenience init(@ArrayBuilder<Disposable> builder: () -> [Disposable]) {
        let disposables = builder()
        self.init(disposing: disposables)
    }
}
