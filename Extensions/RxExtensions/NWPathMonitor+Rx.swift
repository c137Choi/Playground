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
    
    var satisfiedEthernetPath: RxObservable<NWPath?> {
        satisfiedPath.map {
            $0.usesInterfaceType(.wifi) || $0.usesInterfaceType(.wiredEthernet) ? $0 : nil
        }
    }
    
    var satisfiedPath: RxObservable<NWPath> {
        currentPath.filter {
            $0.status == .satisfied
        }
    }
    
    /// 注: 这里不使用.distinctUntilChanged()过滤重复项
    /// 因为外部可能需要在网络接口变化时重新建立网络连接(即使是重复的Path也代表着网络接口的变化)
    var currentPath: RxObservable<NWPath> {
        RxObservable.create {
            [weak monitor = base] observer in
            guard let monitor else {
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(monitor.currentPath)
            monitor.pathUpdateHandler = { path in
                observer.onNext(path)
            }
            let queue = DispatchQueue(label: "com.nw.path.monitor", qos: .userInitiated, autoreleaseFrequency: .workItem)
            monitor.start(queue: queue)
            return Disposables.create {
                [weak monitor] in monitor?.cancel()
            }
        }
    }
}
