//
//  AVAssetPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/5/12.
//

import AVFoundation

extension AVAsset {
    
    /// 判断是否为HDR视频
    var isHDRVideo: Bool {
        tracks(withMediaType: .video).lazy.first.or(false, map: \.isHDRVideo)
    }
}
