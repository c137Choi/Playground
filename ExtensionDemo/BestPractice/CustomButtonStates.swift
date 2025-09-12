//
//  CustomButtonStates.swift
//  ExtensionDemo
//
//  Created by Choi on 2025/9/12.
//  Copyright © 2025 Choi. All rights reserved.
//

import UIKit

extension UIControl.State {
	/// 可用范围比特位为: UIControl.State.application
	/// 即: 0b0000_0000_1111_1111_0000_0000_0000_0000, 向左移位16-23为合法范围
	static let state16 = UIControl.State(rawValue: 1 << 16)
	static let state17 = UIControl.State(rawValue: 1 << 17)
	static let state18 = UIControl.State(rawValue: 1 << 18)
	static let state19 = UIControl.State(rawValue: 1 << 19)
	static let state20 = UIControl.State(rawValue: 1 << 20)
	static let state21 = UIControl.State(rawValue: 1 << 21)
	static let state22 = UIControl.State(rawValue: 1 << 22)
	static let state23 = UIControl.State(rawValue: 1 << 23)
}

extension UIControl.Event {
	/// 可用范围比特位为: UIControl.Event.applicationReserved
	/// 即: 0b0000_1111_0000_0000_0000_0000_0000_0000, 向左移位24-27为合法范围
	static let event24 = UIControl.Event(rawValue: 1 << 24)
	static let event25 = UIControl.Event(rawValue: 1 << 25)
	static let event26 = UIControl.Event(rawValue: 1 << 26)
	static let event27 = UIControl.Event(rawValue: 1 << 27)
}

final class CustomStatesButton: UIButton {
	
	/// 外部更新了customState之后需要调用UIButton扩展方法里的setStateUpdated()方法以触发状态更新
	var customState: UIControl.State?

	override var state: UIControl.State {
		if let customState {
			return super.state.union(customState)
		} else {
			return super.state
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		
		setTitle("normal", for: .normal)
		setTitle("highlighted", for: .highlighted)
		
		setTitle("state16", for: .state16)
		setTitle("state16", for: .state16.unionHighlighted)
		
		setTitle("state17", for: .state17)
		setTitle("state17", for: .state17.unionHighlighted)
		
		setTitle("state18", for: .state18)
		setTitle("state18", for: .state18.unionHighlighted)
		
		setTitle("state19", for: .state19)
		setTitle("state19", for: .state19.unionHighlighted)
		
		setTitle("state20", for: .state20)
		setTitle("state20", for: .state20.unionHighlighted)
		
		setTitle("state21", for: .state21)
		setTitle("state21", for: .state21.unionHighlighted)
		
		setTitle("state22", for: .state22)
		setTitle("state22", for: .state22.unionHighlighted)
		
		setTitle("state23", for: .state23)
		setTitle("state23", for: .state23.unionHighlighted)
		
		addTarget(self, action: #selector(tapMyself), for: .touchUpInside)
	}
	
	@objc func tapMyself() {
		if customState == .none {
			customState = .state16
		} else if customState == .state16 {
			customState = .state17
		} else if customState == .state17 {
			customState = .state18
		} else if customState == .state18 {
			customState = .state19
		} else if customState == .state19 {
			customState = .state20
		} else if customState == .state20 {
			customState = .state21
		} else if customState == .state21 {
			customState = .state22
		} else if customState == .state22 {
			customState = .state23
		} else if customState == .state23 {
			customState = .state16
		}
	}
}
