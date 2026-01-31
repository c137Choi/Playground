//
//  GlobalFunctions.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/2/25.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

func lprint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    print(items, separator: separator, terminator: terminator)
#endif
}

func dprint(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #fileID, function: String = #function, line: Int = #line) {
#if DEBUG
    let now = Date.now
    var fileName = (file as NSString).lastPathComponent
    let swiftExtension = ".swift"
    if fileName.hasSuffix(swiftExtension) {
        fileName.removeLast(swiftExtension.count)
    }
    let threadWarning = Thread.isMainThread ? "" : " | NOT-MAIN-THREAD"
    let queueWarning = isMainQueue ? "" : " | NOT-MAIN-QUEUE"
    print("🍌 @Time \(now.debugFormatted) \(fileName).\(function) @Line:\(line)\(threadWarning)\(queueWarning)")
    print(items, separator: separator, terminator: terminator)
#endif
}

var isDebugging: Bool {
#if DEBUG
    true
#else
    false
#endif
}

/// 是否为真机环境
var isRealDevice: Bool { !isSimulator }

/// 是否为模拟器环境
var isSimulator: Bool {
#if targetEnvironment(simulator)
    true
#else
    false
#endif
}

/// 判断是否是主队列
fileprivate let mainQueueSpecificKey = DispatchSpecificKey<UUID>()
fileprivate let mainQueueID = UUID()
var isMainQueue: Bool {
	Dispatch.once {
		DispatchQueue.main.setSpecific(key: mainQueueSpecificKey, value: mainQueueID)
	}
	return DispatchQueue.getSpecific(key: mainQueueSpecificKey) == mainQueueID
}

/// 获取当前队列名称
var currentQueueName: String? {
    String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)
}

/// 同步锁
/// - Parameters:
///   - obj: 锁对象
///   - action: 创建回调
/// - Returns: 对象实例
func synchronized<T>(lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    return try closure()
}

/// 使用左边的参数 | 常见于Dictionary.merge方法
func <--<T>(_ lhs: T, rhs: T) -> T { lhs }
/// 使用右边的参数 | 常见于Dictionary.merge方法
func --><T>(_ lhs: T, rhs: T) -> T { rhs }
/// 是否为连续的两个数字
func contiguousNumbers(_ last: Int, _ latest: Int) -> Bool {
    latest == last + 1
}

/// 方法转换
/// - Parameters:
///   - value: 被引用的对象
///   - closure: 具体的执行代码
/// - Returns: A closure
func combine<A, B>(_ value: A, with closure: @escaping (A) -> B) -> () -> B {
    {
        closure(value)
    }
}

/// 方法转换
/// - Parameter output: 默认返回值
/// - Returns: A Closure which will return the output by default.
func sink<In, Out>(_ output: Out) -> (In) -> Out {
    { _ in output }
}

func sink<In>(_ simpleCallBack: @escaping SimpleCallback) -> (In) -> Void {
    { _ in simpleCallBack() }
}

/// 通过KeyPath获取属性的Setter方法, 为属性赋值
func setter<Object: AnyObject, Value>(for object: Object, keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Void {
    {
        [weak object] value in object?[keyPath: keyPath] = value
    }
}

/// 隐藏键盘
func dismissKeyboard() {
    /// to: 指定参数为nil, 此方法会将Action发送给当前的第一响应者, 从而达到隐藏键盘的效果
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func associated<T>(_ type: T.Type, _ object: Any, _ key: UnsafeRawPointer) -> T? {
    getAssociatedObject(object, key) as? T
}

func getAssociatedObject(_ object: Any, _ key: UnsafeRawPointer) -> Any? {
    objc_getAssociatedObject(object, key)
}

func setAssociatedObject(_ object: Any, _ key: UnsafeRawPointer, _ value: Any?, _ policy: objc_AssociationPolicy) {
    objc_setAssociatedObject(object, key, value, policy)
}
