//
//  NWConnectionPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/3/12.
//

import Network
import RxSwift
import RxCocoa

extension NWConnection: @retroactive ReactiveCompatible {}

extension Reactive where Base == NWConnection {
    
    var state: Observable<NWConnection.State> {
        Observable.create {
            [weak base] observer in
            /// 默认返回值
            let disposable = Disposables.create()
            /// 解包base
            guard let connection = base else { return disposable }
            /// 发送初始值
            observer.onNext(connection.state)
            /// 监听状态
            connection.stateUpdateHandler = { state in
                switch state {
                case .setup:
                    observer.onNext(state)
                case .waiting:
                    observer.onNext(state)
                case .preparing:
                    observer.onNext(state)
                case .ready:
                    observer.onNext(state)
                case .failed(let error):
                    observer.onError(error)
                case .cancelled:
                    observer.onNext(state)
                    observer.onCompleted()
                @unknown default:
                    assertionFailure("Unknown state")
                    observer.onCompleted()
                }
            }
            return disposable
        }
    }
}
