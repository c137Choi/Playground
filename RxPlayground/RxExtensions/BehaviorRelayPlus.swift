//
//  BehaviorRelayPlus.swift
//  RxPlayground
//
//  Created by Choi on 2022/4/20.
//

import RxSwift
import RxCocoa

extension BehaviorRelay {

    /// Accept update of current value
    /// - Parameter update: mutate current value in closure
    func acceptModifiedValue(byMutating update: (inout Element) -> Void) {
        var newValue = value
        update(&newValue)
        accept(newValue)
    }

    /// Accept new value generated from current value
    /// - Parameter update: generate new value from current, and return it
    func acceptUpdate(byNewValue update: (Element) -> Element) {
        accept(update(value))
    }

    static func <<(lhs: BehaviorRelay<Element>, rhs: Element) {
        lhs.accept(rhs)
    }
}

extension BehaviorRelay where Element: RangeReplaceableCollection {

    func append(_ subElement: Element.Element) {
        var newValue = value
        newValue.append(subElement)
        accept(newValue)
    }

    func append(_ contentsOf: [Element.Element]) {
        var newValue = value
        newValue.append(contentsOf: contentsOf)
        accept(newValue)
    }

    public func remove(at index: Element.Index) {
        var newValue = value
        newValue.remove(at: index)
        accept(newValue)
    }

    public func removeAll() {
        var newValue = value
        newValue.removeAll()
        accept(newValue)
    }
}

extension BehaviorRelay: @retroactive ObserverType {
    
    public func on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            accept(element)
        default:
            break
        }
    }
}
