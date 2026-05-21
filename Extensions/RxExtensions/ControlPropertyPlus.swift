//
//  ControlPropertyPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/8/21.
//

import RxSwift
import RxCocoa

extension ControlProperty {
    
    init<Values: ObservableType, Target: AnyObject>(values: Values, target: Target, binding: @escaping (Target, PropertyType) -> Void) where Values.Element == PropertyType {
        let binder = Binder(target, binding: binding)
        self.init(values: values, valueSink: binder)
    }
}
