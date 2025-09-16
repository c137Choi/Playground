//
//  NSObjectPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2020/7/29.
//  Copyright © 2020 Choi. All rights reserved.
//

import Foundation

extension NSObject {
	
    enum Associated {
        @UniqueAddress static var targets
        @UniqueAddress static var isPrepared
    }
    
    var targets: [AnyHashable: Any] {
        get {
            if let dict = associated([AnyHashable: Any].self, self, Associated.targets) {
                return dict
            } else {
                let dict = [AnyHashable: Any].empty
                setAssociatedObject(self, Associated.targets, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return dict
            }
        }
        set {
            setAssociatedObject(self, Associated.targets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否准备好标记: 默认为true
    var isPrepared: Bool {
        get {
            synchronized(lock: self) {
                guard let prepared = associated(Bool.self, self, Associated.isPrepared) else {
                    /// 默认初始值
                    let initialValue = true
                    setAssociatedObject(self, Associated.isPrepared, initialValue, .OBJC_ASSOCIATION_ASSIGN)
                    return initialValue
                }
                return prepared
            }
        }
        set(prepared) {
            synchronized(lock: self) {
                setAssociatedObject(self, Associated.isPrepared, prepared, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
	/// 转换成指针
	public var rawPointer: UnsafeMutableRawPointer {
		Unmanaged.passUnretained(self).toOpaque()
	}
	
	var proxy: _NSObjectProxy<NSObject> {
		_NSObjectProxy(target: self)
	}
	
	func proxy<T>(_ target: T) -> _NSObjectProxy<T> where T: NSObjectProtocol {
		_NSObjectProxy(target: target)
	}
}

final class _NSObjectProxy<T: NSObjectProtocol>: NSObject {
	
	private(set) weak var _target: T!
	var target: T {
		_target
	}
	
	init(target: T){
		_target = target
		super.init()
	}
	
	//  核心代码
	override func forwardingTarget(for aSelector: Selector!) -> Any? {
		_target
	}
	
	// NSObject 一些方法复写
	override func isEqual(_ object: Any?) -> Bool {
		_target.isEqual(object)
	}
	
	override var hash: Int {
		_target.hash
	}
	
	override var superclass: AnyClass? {
		_target.superclass ?? nil
	}
	
	func `self`() -> T {
		_target.self
	}
	
	override func isProxy() -> Bool {
		true
	}
	
	override func isKind(of aClass: AnyClass) -> Bool {
		_target.isKind(of: aClass)
	}
	
	override func isMember(of aClass: AnyClass) -> Bool {
		_target.isMember(of: aClass)
	}
	
	override func conforms(to aProtocol: Protocol) -> Bool {
		_target.conforms(to: aProtocol)
	}
	
	override func responds(to aSelector: Selector!) -> Bool {
		_target.responds(to: aSelector)
	}
	
	override var description: String {
		_target.description
	}
	
	override var debugDescription: String {
		_target.debugDescription
	}
}
