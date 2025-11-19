//
//  CoreFoundationPlus.swift
//
//  Created by Choi on 2022/9/5.
//

import Foundation

extension CFString {
    var string: String {
        self as String
    }
}

extension CFDictionary {
    
    var nsDictionary: NSDictionary {
        self as NSDictionary
    }
}
