//
//  ResultPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/9.
//

import Foundation

extension Result {
    
    var success: Success? {
        switch self {
        case .success(let success):
            return success
        case .failure:
            return nil
        }
    }
    
    var failure: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let failure):
            return failure
        }
    }
}
