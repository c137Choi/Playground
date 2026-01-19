//
//  AVAssetTrack.swift
//  KnowLED
//
//  Created by Choi on 2025/5/12.
//

import AVFoundation

extension AVAssetTrack {
    
    /// 判断是否为HDR视频
    var isHDRVideo: Bool {
        guard mediaType == .video else { return false }
        return hasMediaCharacteristic(.containsHDRVideo)
    }
}
