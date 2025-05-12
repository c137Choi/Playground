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
        guard let formatDescription = formatDescriptions.lazy.first.as(CMFormatDescription.self) else { return false }
        /// extensionKey: Can be nil, which will make the as! CFString fail
        guard let transferFunction = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCVImageBufferTransferFunctionKey) else { return false }
        let functions = [
            kCVImageBufferTransferFunction_ITU_R_2020,
            kCVImageBufferTransferFunction_ITU_R_2100_HLG,
            kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ
        ]
        return functions.contains(transferFunction as! CFString)
    }
}
