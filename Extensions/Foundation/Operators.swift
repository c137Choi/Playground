//
//  Operators.swift
//  ExtensionDemo
//
//  Created by Choi on 2022/6/19.
//  Copyright © 2022 Choi. All rights reserved.
//

import Foundation

// MARK: - __________ 优先级组 __________

// MARK: - __________ 操作符 __________
infix operator <<- : MultiplicationPrecedence
infix operator <-- : MultiplicationPrecedence
infix operator --> : MultiplicationPrecedence
infix operator <-> : MultiplicationPrecedence
infix operator +> : MultiplicationPrecedence
infix operator +- : MultiplicationPrecedence
infix operator ??= : AssignmentPrecedence
infix operator ?= : AssignmentPrecedence

// MARK: - __________ Conditional Assignment 具体实现 __________
/// 唯空赋值运算符: To assign only if the assigned-to variable is nil
func ??= <T>(lhs: inout T?, rhs: T?) {
	guard lhs == nil else { return }
	lhs = rhs
}
/// 右侧Optional有效时才赋值
#if swift(>=5.7)
func ?= <T>(lhs: inout T?, rhs: T?) {
	guard let rhs else { return }
	lhs = rhs
}
#endif
/// 给String?赋值时总是赋新值
func ?= (lhs: inout String?, rhs: String) {
	lhs = rhs
}
/// 右侧值不为空字符串时才赋值
func ?= (lhs: inout String?, rhs: String?) {
	guard rhs.isValidString else { return }
	lhs = rhs
}
func ?= (lhs: inout String, rhs: String) {
	guard rhs.isValidString else { return }
	lhs = rhs
}
