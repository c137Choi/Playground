//
//  UITextField+Rx.swift
//
//  Created by Choi on 2023/2/22.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
    
    /// 编辑状态的UnmarkedText
    /// 注: 需要与QMUITextField配合使用, 设置其.shouldResponseToProgrammaticallyTextChanges为false
    /// 再订阅此事件
    /// - Parameter skipFirstEditingText: 是否跳过每一次进入编辑状态时的text值
    func typingUnmarkedText(skipFirstEditingText: Bool) -> Observable<String> {
        isEditing.observable
            .withUnretained(base)
            .flatMapLatest { textField, isEditing -> Observable<String> in
                if isEditing {
                    return text.withUnretained(textField)
                        .map(\.0.unmarkedText)
                        .unwrapped
                        .skip(skipFirstEditingText ? 1 : 0)
                } else {
                    return .empty()
                }
            }
    }
    
    var isEditing: Driver<Bool> {
        controlEvent([.editingDidBegin, .editingDidEnd])
            .withUnretained(base)
            .map(\.0.isEditing)
            .startWith(base.isEditing)
            .asDriver(onErrorJustReturn: false)
    }
    
    var unmarkedTextInput: TextInput<Base> {
        TextInput(base: base, text: maybeUnmarkedText)
    }
    
    var unmarkedText: ControlProperty<String> {
        maybeUnmarkedText.orEmpty
    }
    
    var maybeUnmarkedText: ControlProperty<String?> {
        let setUnmarked = Binder<String?>(base) { textField, unmarked in
            /// 避免循环调用
            guard textField.text != unmarked else { return }
            /// 赋值
            textField.text = unmarked
        }
        return ControlProperty(values: observedUnmarkedText.optionalElement, valueSink: setUnmarked)
    }
    
    private var observedUnmarkedText: Observable<String> {
        /// 注意这里observedText的后面不能加.distinctUntilChanged()操作符
        /// 否则拼音字符编辑完成后会出现unmarkedText事件不发送的问题
        /// 因为在输入拼音时,UITextField的.editingChanged事件会在拼音编辑完成时调用两次
        /// 只有第二次的时候才能获取到unmarkedText
        observedText
            .withUnretained(base)
            .map(\.0.unmarkedText)
            .distinctUntilChanged()
            .orEmpty
    }
    
    var observedText: Observable<String?> {
        /// 分别用于观察直接赋值时的文本变化和编辑时的文本变化
        Observable.merge(observe(\.text), text.observable)
    }
}
