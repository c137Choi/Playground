//
//  ResultBuilders.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/7/29.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

@resultBuilder enum ArrayBuilder<E> {
	
	static func buildEither(first component: [E]) -> [E] {
		component
	}
	
	static func buildEither(second component: [E]) -> [E] {
		component
	}
	
	static func buildOptional(_ component: [E]?) -> [E] {
		component ?? []
	}
	
	static func buildExpression(_ expression: E) -> [E] {
		[expression]
	}
	
	static func buildExpression(_ expression: [E]) -> [E] {
		expression
	}
	
	static func buildExpression(_ expression: ()) -> [E] {
		[]
	}
	
	static func buildExpression(_ expression: E?) -> [E] {
		if let element = expression {
			return [element]
		} else {
			return []
		}
	}
	
	static func buildBlock(_ components: [E]...) -> [E] {
		components.flatMap { $0 }
	}
	
	static func buildArray(_ components: [[E]]) -> [E] {
		Array(components.joined())
	}
}

extension ArrayBuilder where E: Hashable {
	
	static func buildExpression(_ expression: Set<E>) -> [E] {
		expression.array
	}
}

@resultBuilder
enum SingleValueBuilder<E> {
	static func buildBlock(_ components: E) -> E {
		components
	}
	static func buildEither(first component: E) -> E {
		component
	}
	static func buildEither(second component: E) -> E {
		component
	}
	static func buildOptional(_ component: E) -> E {
		component
	}
	static func buildLimitedAvailability(_ component: E) -> E {
		component
	}
}

// MARK: - __________ Constraints Builder __________
protocol ConstraintGroup {
	var constraints: [NSLayoutConstraint] { get }
}
extension NSLayoutConstraint: ConstraintGroup {
	var constraints: [NSLayoutConstraint] { [self] }
}
extension Array: ConstraintGroup where Element == NSLayoutConstraint {
	var constraints: [NSLayoutConstraint] { self }
}

// MARK: Best Practice
extension NSLayoutConstraint {
	static func activate(@ArrayBuilder<NSLayoutConstraint> constraintsBuilder: () -> [NSLayoutConstraint]) {
		let constraints = constraintsBuilder()
		activate(constraints)
	}
}

protocol SubviewContaining {}
extension UIView: SubviewContaining {}
extension SubviewContaining where Self: UIView {
	func add<SubView: UIView>(subView: SubView, @ArrayBuilder<NSLayoutConstraint> constraintsBuilder: (SubView) -> [NSLayoutConstraint]) {
		subView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(subView)
		let constraints = constraintsBuilder(subView)
		NSLayoutConstraint.activate(constraints)
	}
}
fileprivate func testConstraintsBuilder() {
	let container = UIView()
	let subView = UIView()
	let offset: CGFloat? = nil
	let value: Int = 0
	container.add(subView: subView) { sub in
		sub.widthAnchor.constraint(equalToConstant: 200)
		if let offset = offset {
			sub.topAnchor.constraint(equalTo: container.topAnchor, constant: offset)
		}
		if value > 0 {
			sub.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		} else {
			sub.rightAnchor.constraint(equalTo: container.rightAnchor)
		}
	}
}
