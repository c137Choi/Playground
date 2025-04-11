//
//  NWPathPlus.swift
//
//  Created by Choi on 2023/3/3.
//

import Network

/// IPv4配置
struct IPv4Config: CustomStringConvertible {
    /// IP地址
    var ip: IPv4Address?
    /// 子网掩码
    var subnetMask: IPv4Address?
    /// 广播地址
    var broadCastIP: IPv4Address?
    
    init(ip: IPv4Address? = nil, subnetMask: IPv4Address? = nil, broadCastIP: IPv4Address? = nil) {
        self.ip = ip
        self.subnetMask = subnetMask
        self.broadCastIP = broadCastIP
    }
    
    var description: String {
        "\(ip.or(.broadcast).debugDescription)/\(subnetMask.or(.broadcast).debugDescription)/\(broadCastIP.or(.broadcast).debugDescription)"
    }
}

extension NWPath {
    
    var ipv4Config: IPv4Config? {
        
        guard let interfaceName = availableInterfaces.map(\.name).first else { return nil }
        
        /// 最终的IP地址
        var ipAddress: String?
        /// 最终的子网掩码
        var netmask: String?
        /// 最终的广播地址
        var broadcast: String?

        /// 获取本地所有的接口列表
        var ifaddrs: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrs) == 0 else { return nil }
        guard let ifaddrs else { return nil }

        /// 遍历所有接口
        for ifaddr in sequence(first: ifaddrs, next: \.pointee.ifa_next) {
            let pointee = ifaddr.pointee
            
            /// IP版本
            let saFamily = pointee.ifa_addr.pointee.sa_family
            /// IPv4
            if saFamily == UInt8(AF_INET) {
                /// 接口名称(e.g. :en0 en1 etc.)
                let name = String(cString: pointee.ifa_name)
                if name == interfaceName {
                    /// 将接口地址转换为人类可读的字符串
                    var ipAddressChars = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    var netmaskChars = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    var broadcastChars = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    /// 获取IP地址
                    getnameinfo(pointee.ifa_addr,
                                socklen_t(pointee.ifa_addr.pointee.sa_len),
                                &ipAddressChars,
                                socklen_t(ipAddressChars.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    
                    /// 获取子网掩码
                    var netmaskPointee = pointee.ifa_netmask.pointee
                    getnameinfo(&netmaskPointee,
                                socklen_t(netmaskPointee.sa_len),
                                &netmaskChars,
                                socklen_t(netmaskChars.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    
                    /// 获取广播地址
                    var broadcastPointee = pointee.ifa_dstaddr.pointee
                    getnameinfo(&broadcastPointee,
                                socklen_t(broadcastPointee.sa_len),
                                &broadcastChars,
                                socklen_t(broadcastChars.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    ipAddress = String(cString: ipAddressChars)
                    netmask = String(cString: netmaskChars)
                    broadcast = String(cString: broadcastChars)
                }
            }
        }
        freeifaddrs(ifaddrs)

        return IPv4Config(
            ip: IPv4Address(ipAddress.orEmpty),
            subnetMask: IPv4Address(netmask.orEmpty),
            broadCastIP: IPv4Address(broadcast.orEmpty)
        )
    }
}
