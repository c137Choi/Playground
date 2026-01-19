//
//  CoreLocation.swift
//  KnowLED
//
//  Created by Choi on 2023/10/21.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus {
    
    var isAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            true
        default:
            false
        }
    }
    
    var isNotDetermined: Bool {
        self == .notDetermined
    }
}
