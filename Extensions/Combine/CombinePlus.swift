//
//  CombinePlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2022/5/30.
//  Copyright © 2022 Choi. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import RxCocoa

nonisolated extension Publisher where Output: OptionalConvertible {
    var unwrapped: AnyPublisher<Output.Wrapped, Failure> {
        compactMap(\.optionalValue).eraseToAnyPublisher()
    }
}

nonisolated func <-> <T>(property: ControlProperty<T>, subject: CurrentValueSubject<T, Never>) -> Disposable {
    let bindToProperty = subject.values.observable.bind(to: property)
    let bindToSubject = property.subscribe(onNext: subject.send, onCompleted: bindToProperty.dispose)
    return Disposables.create(bindToProperty, bindToSubject)
}

nonisolated extension Subject {
    static func << (lhs: Self, rhs: Output) {
        lhs.send(rhs)
    }
}
