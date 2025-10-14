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
