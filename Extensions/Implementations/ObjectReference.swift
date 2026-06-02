//
//  ObjectReference.swift
//  KnowLED
//
//  Created by Choi on 2024/1/3.
//

import Foundation

/// ObjectReference弱引用对象指针, 通常用于解除引用循环
struct ObjectReference<T> where T: AnyObject {
    weak var object: T?
}
