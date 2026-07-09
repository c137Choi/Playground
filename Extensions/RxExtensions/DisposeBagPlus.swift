//
//  DisposeBagPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/19.
//

import RxSwift

nonisolated extension DisposeBag {
    
    static var empty: DisposeBag {
        DisposeBag()
    }
    
    /// 创建DisposeBag并开启任务(不抛出错误)
    static func task(name: String? = nil, priority: TaskPriority? = nil, operation: sending @escaping @isolated(any) () async -> Void) -> DisposeBag {
        DisposeBag {
            Task(name: name, priority: priority, operation: operation)
        }
    }
    
    /// 创建DisposeBag并开启任务(可抛出错误)
    static func task(name: String? = nil, priority: TaskPriority? = nil, operation: sending @escaping @isolated(any) () async throws -> Void) -> DisposeBag {
        DisposeBag {
            Task(name: name, priority: priority, operation: operation)
        }
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
