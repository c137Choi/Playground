//
//  ProgressTracker.swift
//  KnowLED
//
//  Created by Choi on 2026/2/26.
//

import Foundation

protocol ProgressTracker: AnyObject {
    func trackProgress(_ result: Result<Double, Error>)
}

protocol ProgressType {
    /// 这里的属性名参考了Progress对象的同名属性
    var fractionCompleted: Double { get }
}

extension Progress: ProgressType {}
