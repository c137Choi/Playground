//
//  RxPlus.swift
//  RxPlayground
//
//  Created by Choi on 2021/4/16.
//

import RxSwift
import RxCocoa
import Combine

public typealias RxEvent = RxSwift.Event
public typealias RxError = RxSwift.RxError
public typealias RxObservable = RxSwift.RxObservable

/// RxEvent类型的简化版
@frozen public enum RxEventLite {
    case next
    case error
    case completed
}

/// Rx序列生命周期
public enum RxLifecycle {
    case next
    case afterNext
    case error
    case afterError
    case completed
    case afterCompleted
    case subscribe
    case subscribed
    case dispose
}

/// 扩展RxEvent遵循Equatable协议 | 其Element同时必须是Equatable
extension RxEvent: @retroactive Equatable where Element: Equatable {
    
    /// 只对比.next和.completed事件, 因为Error协议无法对比, 故其他情况一律返回false
    public static func == (lhs: RxEvent<Element>, rhs: RxEvent<Element>) -> Bool {
        switch (lhs, rhs) {
        case (.next(let leftElement), .next(let rightElement)):
            return leftElement == rightElement
        case (.completed, .completed):
            return true
        default:
            return false
        }
    }
}

#if os(iOS)
func <-> <Base>(textInput: TextInput<Base>, relay: BehaviorRelay<String>) -> Disposable {
    let bindToProperty = relay.bind(to: textInput.text)
    let bindToRelay = textInput.text.subscribe {
        [weak input = textInput.base] _ in
        /**
         In some cases `textInput.textRangeFromPosition(start, toPosition: end)` will return nil even though the underlying
         value is not nil. This appears to be an Apple bug. If it's not, and we are doing something wrong, please let us know.
         The can be reproed easily if replace bottom code with
         
         if nonMarkedTextValue != relay.value {
            relay.accept(nonMarkedTextValue ?? "")
         }

         and you hit "Done" button on keyboard.
         */
        if let input, let unmarkedText = input.unmarkedText, unmarkedText != relay.value {
            relay.accept(unmarkedText)
        }
        
    } onCompleted: {
        bindToProperty.dispose()
    }
    
    return Disposables.create(bindToProperty, bindToRelay)
}
#endif

func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    if T.self == String.self {
#if DEBUG && !os(macOS)
        fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx.text` property directly to relay.\n" +
            "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
            "REMEDY: Just use `textField <-> relay` instead of `textField.rx.text <-> relay`.\n" +
            "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
#endif
    }

    let bindToProperty = relay.bind(to: property)
    let bindToRelay = property.subscribe(onNext: relay.accept, onCompleted: bindToProperty.dispose)
    return Disposables.create(bindToProperty, bindToRelay)
}
