//
//  UInt16Plus.swift
//  KnowledPhone
//
//  Created by Choi on 2025/9/27.
//

import Foundation

extension UInt16 {
	
	/// 转换成两个字节
	@ArrayBuilder<UInt8> var bytes: [UInt8] {
		UInt8(truncatingIfNeeded: self >> 8)
		UInt8(truncatingIfNeeded: self & 0x00FF)
	}
}
