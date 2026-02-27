//
//  URLComponentsPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/12/26.
//

import Foundation

extension URLComponents {
    
    init(scheme: String?, host: String?) {
        self.init()
        self.scheme = scheme
        self.host = host?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    init(scheme: String?, encodedHost: String?) {
        self.init()
        self.scheme = scheme
        if #available(iOS 16, *) {
            self.encodedHost = encodedHost
        } else {
            self.host = encodedHost
        }
    }
}
