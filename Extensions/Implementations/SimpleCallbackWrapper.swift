//
//  SimpleCallbackWrapper.swift
//  ExtensionDemo
//
//  Created by Choi on 2022/6/28.
//  Copyright © 2022 Choi. All rights reserved.
//

import Foundation

final class SimpleCallbackWrapper: NSObject {
	let callback: SimpleCallback
	init(_ callback: @escaping SimpleCallback) {
		self.callback = callback
	}
}
