//
//  ProgressIndicator.swift
//  KnowLED
//
//  Created by Choi on 2026/2/26.
//

import RxSwift

public final class ProgressIndicator: ObservableConvertibleType {
    
    private let progress: Progress
    
    private let subject: BehaviorSubject<Progress>
    
    private let lock = NSLock()
    
    init(totalUnitCount: Int) {
        let progress = Progress(totalUnitCount: totalUnitCount.int64)
        self.progress = progress
        self.subject = BehaviorSubject(value: progress)
    }
    
    func track<T>(_ source: T) -> Observable<T.Element> where T: ObservableConvertibleType {
        let onCompleted: ThrowsSimpleCallback = {
            [weak self] in
            guard let self else { return }
            /// 更新进度
            lock.lock()
            progress.completedUnitCount += 1
            lock.unlock()
            /// 发送事件
            subject.onNext(progress)
        }
        return source
            .asObservable()
            .do(onCompleted: onCompleted)
    }
    
    public func asObservable() -> Observable<Progress> {
        subject.asObservable()
    }
}
