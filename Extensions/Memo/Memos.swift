//
//  Memos.swift
//  KnowLED
//
//  Created by Choi on 2025/2/17.
//

import Foundation

enum Memos {
    
    /// 移动单个或多个项目到指定位置时
    /// 考虑根据向前/向后移动算出目标Offset
    private func moveFromOffsets() {
        let a = IndexPath(item: 0, section: 0)
        let b = IndexPath(item: 1, section: 0)
        let target = IndexPath(item: 2, section: 0)
        var abOffsets = IndexSet()
        abOffsets.insert(a.item)
        abOffsets.insert(b.item)
        /// 是否向后移动
        let moveBackward = b.item < target.item
        /// 目标偏移 | 如果是前面的项目挪到后面则目标偏移需要加一
        let toOffset = moveBackward ? target.item + 1 : target.item
        var array = [1, 2, 3]
        array.move(fromOffsets: abOffsets, toOffset: toOffset)
        print(array)
    }
}
