//
//  AppLog.swift
//  KnowLED
//

import UIKit

/// 应用运行日志
/// 仅在 alpha 测试包与 Debug 构建下记录: 每次启动在沙盒 Documents/AppLog 下新建一个日志文件(目录不存在时自动创建), 文件名取启动时间(精确到秒);
/// dprint/lprint 的输出都会追加写入该文件, Release 正式包不产生任何日志读写
/// 日志可能来自任意线程(dprint/lprint 为 nonisolated), 故声明为 nonisolated; 可变状态仅在串行队列上访问
nonisolated final class AppLog: @unchecked Sendable {
    
    static let shared = AppLog()
    
    /// 是否开启日志(仅 alpha 测试包与 Debug 构建, 正式包不产生任何日志读写)
    let isEnabled = isAlphaTest || isDebugging
    
    /// 串行写入队列: 日志可能来自任意线程, 统一在此队列上写文件, 保证写入顺序与线程安全
    private let queue = DispatchQueue(label: "com.godox.knowled.applog", qos: .utility)
    /// 日志行时间戳格式: HH:mm:ss.SSS(精确到毫秒, 便于对齐并发/时序问题)
    /// 固定24小时制与公历, 不受系统区域/小时制设置影响
    private let timestampFormatStyle = Date.VerbatimFormatStyle(
        format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits).\(secondFraction: .fractional(3))",
        locale: .english,
        timeZone: .autoupdatingCurrent,
        calendar: .gregorian
    )
    /// 日志文件名格式: yyyy-MM-dd HH-mm-ss
    private let fileNameFormatStyle = Date.VerbatimFormatStyle(
        format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))-\(minute: .twoDigits)-\(second: .twoDigits)",
        locale: .english,
        timeZone: .autoupdatingCurrent,
        calendar: .gregorian
    )
    /// 当前运行的日志文件
    private var fileHandle: FileHandle?
    /// 定时落盘: 未切后台/异常退出时也能把缓冲区写入文件(最长延迟1秒)
    private var flushTimer: DispatchSourceTimer?
    /// 待写入的数据(批量落盘, 避免每条日志都触发一次文件写入)
    private var buffer = Data()
    /// 缓冲区达到该大小即落盘
    private let flushThreshold = 32 * 1024
    
    private init() {}
    
    /// 创建本次运行的日志文件(启动时调用)
    @MainActor func start() {
        guard isEnabled else { return }
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let device = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion) | \(UIDevice.current.model)"
        queue.async { [self] in
            let directoryURL = URL.documentDirectory.appendingPathComponent("AppLog", isDirectory: true)
            try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let fileURL = directoryURL
                .appendingPathComponent(Date.now.formatted(fileNameFormatStyle))
                .appendingPathExtension("log")
            guard FileManager.default.createFile(atPath: fileURL.path, contents: nil),
                  let handle = try? FileHandle(forWritingTo: fileURL) else { return }
            fileHandle = handle
            appendToBuffer("===== App 启动 | 版本 \(version)(\(build)) | \(device) =====")
            /// 定时落盘: 测试员操作后即使未切后台, 日志也最多延迟1秒写入文件
            let timer = DispatchSource.makeTimerSource(queue: queue)
            timer.schedule(deadline: DispatchTime.now() + .seconds(1), repeating: .seconds(1))
            timer.setEventHandler { [weak self] in
                self?.flushBuffer()
            }
            timer.resume()
            flushTimer = timer
        }
    }
    
    /// 追加一条日志(自动添加时间戳), 任意线程可调用
    func log(_ message: String) {
        guard isEnabled else { return }
        queue.async { [self] in
            let timestamp = Date.now.formatted(timestampFormatStyle)
            appendToBuffer("[\(timestamp)] \(message)")
        }
    }
    
    /// 把缓冲区剩余内容写入文件(切后台/退出前调用, 保证日志完整)
    func synchronize() {
        queue.async { [self] in
            flushBuffer()
        }
    }
    
    /// 追加到缓冲区, 满则落盘(仅在串行队列上调用)
    private func appendToBuffer(_ text: String) {
        guard fileHandle != nil else { return }
        buffer.append(Data(text.utf8))
        buffer.append(Data("\n".utf8))
        guard buffer.count >= flushThreshold else { return }
        flushBuffer()
    }
    
    /// 落盘并清空缓冲区(仅在串行队列上调用)
    private func flushBuffer() {
        guard !buffer.isEmpty, let fileHandle else { return }
        try? fileHandle.write(contentsOf: buffer)
        buffer.removeAll(keepingCapacity: true)
    }
}
