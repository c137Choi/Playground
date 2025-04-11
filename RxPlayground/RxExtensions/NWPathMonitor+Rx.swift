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
        .distinctUntilChanged()
        .share(replay: 1, scope: .whileConnected)
    }
}
