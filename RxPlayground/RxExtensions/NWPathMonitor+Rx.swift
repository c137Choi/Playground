//
//  NWPathMonitor+Rx.swift
//  KnowLED
//
//  Created by Choi on 2023/10/23.
//

import Foundation
import Network
import RxSwift
import RxCocoa

extension NWPathMonitor: @retroactive ReactiveCompatible {}
extension Reactive where Base == NWPathMonitor {
    
    var satisfiedEthernetPath: Observable<NWPath?> {
        func satisfiedEthernetPath(_ path: NWPath) -> NWPath? {
            (path.status == .satisfied ? path : nil).flatMap { path in
                guard path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet) else { return nil }
                return path
            }
        }
        return currentPath.map(satisfiedEthernetPath)
    }
    
    /// 注: 这里不使用.distinctUntilChanged()过滤重复项
    /// 因为外部可能需要在网络接口变化时重新建立网络连接(即使是重复的Path也代表着网络接口的变化)
    var currentPath: Observable<NWPath> {
        Observable.create {
            [weak monitor = base] observer in
            guard let monitor else {
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(monitor.currentPath)
            monitor.pathUpdateHandler = { path in
                observer.onNext(path)
            }
            let queue = DispatchQueue(label: "com.nw.path.monitor", qos: .userInitiated)
            monitor.start(queue: queue)
            return Disposables.create {
                [weak monitor] in monitor?.cancel()
            }
        }
    }
}
