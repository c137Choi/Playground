//
//  StringPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/7.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit
import Network

// MARK: - __________ String To Date __________

extension String {
    func date(dateFormat: String) -> Date {
        let formatter = DateFormatter.shared
        formatter.dateFormat = dateFormat
        return formatter.date(from: self) ?? Date.now
    }
}

extension String {
    
    public func systemImage(pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular, scale: UIImage.SymbolScale = .default) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)
        return UIImage(systemName: self, withConfiguration: config)
    }
}

// MARK: - __________ String: LocalizedError __________
extension String: @retroactive LocalizedError {
	public var errorDescription: String? {
		self
	}
}

// MARK: - __________ String? __________
extension Optional where Wrapped == String {
	
    var orEmpty: String {
        self ?? ""
    }
	
    var isNotEmptyString: Bool {
        isEmptyString.toggled
    }
    
	/// 判断Optional<String>类型是否为空(.none或Wrapped为空字符串)
	var isEmptyString: Bool {
		switch self {
			case .some(let wrapped): return wrapped.isEmptyString
			case .none: return true
		}
	}
	
	/// 判断Optional是否有效(Wrapped非空字符串)
	var isValidString: Bool {
		!isEmptyString
	}
	
	/// 返回有效的字符串或空字符串
	var unwrappedValidString: Wrapped {
		isEmptyString ? "" : unsafelyUnwrapped
	}
    
    func nonEmptyStringOr(_ defaultValue: Wrapped) -> Wrapped {
        nonEmptyStringOrNil.or(defaultValue)
    }
	
	/// 返回有效的字符串或.none
	var nonEmptyStringOrNil: Self {
		isEmptyString ? .none : unsafelyUnwrapped
	}
    
    /// 转换为字符集
    var characterSet: CharacterSet {
        self.map(fallback: "", \.characterSet)
    }
}

// MARK: - __________ StringProtocol __________
extension StringProtocol {
    
    /// 计算文字尺寸
    func boundingRect(in containerSize: CGSize, fontSize: CGFloat? = nil, fontWeight: UIFont.Weight = .regular) -> CGRect {
        let font = fontSize.map {
            UIFont.systemFont(ofSize: $0, weight: fontWeight)
        }
        return boundingRect(in: containerSize, font: font)
    }
    
    /// 计算文字尺寸
    func boundingRect(in containerSize: CGSize, font: UIFont? = nil) -> CGRect {
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        var attributes: [NSAttributedString.Key: Any] = .empty
        attributes[.font] = font
        return nsString.boundingRect(with: containerSize, options: options, attributes: attributes, context: nil)
    }
    
    /// 转换为NSString
    var nsString: NSString {
        NSString(string: String(self))
    }
    
    /// 将字符串按照指定的进制转换成十进制(字符串不能出现除十六进制字符之外的字符)
    /// FF -> 255
    /// 0000FF -> 255
    /// - Parameter radix: 进制: 取值范围: 2...36
    /// - Returns: 转换成功返回十进制数字
    func intFromRadix(_ radix: Int) -> Int? {
        guard (2...36) ~= radix else {
            assertionFailure("NO SUCH RADIX 🤯")
            return nil
        }
        return Int(self, radix: radix)
    }
    
	/// 返回一个字符串占用多少字节数
	var utf8ByteCount: Int {
		lengthOfBytes(using: .utf8)
	}
	
	var cgFloat: CGFloat? {
        double?.cgFloat
	}
    
    var int: Int? {
        Int(self)
    }
    
	var double: Double? {
		Double(self)
	}
}

// MARK: - __________ Range<String.Index> __________
extension RangeExpression where Bound == String.Index  {
	func nsRange<S: StringProtocol>(in string: S) -> NSRange {
		NSRange(self, in: string)
	}
}

// MARK: - __________ String __________
extension String {
	
	/// 使用右侧的字符串
	/// - Parameters:
	///   - lhs: 左操作对象
	///   - rhs: 右操作对象
	/// - Note: 以下两个方法对于字典类型在合并其他字典时的回调闭包里使用语法糖时较为有用
	/// - Example:　aDict.merging(anotherOne) { $0 << $1 } // 使用当前值(如果直接返回$0会触发编译器错误)
	static func >> (lhs: String, rhs: String) -> String { rhs }
	
	/// 使用左侧的字符串
	/// - Parameters:
	///   - lhs: 左操作对象
	///   - rhs: 右操作对象
	static func << (lhs: String, rhs: String) -> String { lhs }
}
extension String {
    
    fileprivate static var _deviceIdentifier: String?
    
    static func removeDeviceIdentifier() {
        let item = KeychainItem<String>(
            service: KeychainService.deviceInfo.rawValue,
            account: KeychainService.DeviceInfo.deviceIdentifier.rawValue)
        do {
            try item.deleteItem()
            dprint("设备ID删除成功")
        } catch {
            dprint(error)
        }
    }
    
    static var deviceIdentifier: String? {
        if let _deviceIdentifier {
            return _deviceIdentifier
        }
        let item = KeychainItem<String>(
            service: KeychainService.deviceInfo.rawValue,
            account: KeychainService.DeviceInfo.deviceIdentifier.rawValue)
        do {
            let identifier = try item.read()
            _deviceIdentifier = identifier
            return identifier
        } catch KeychainError.noPassword {
            do {
                let newIdentifier = String.randomUUID
                _deviceIdentifier = newIdentifier
                try item.save(newIdentifier)
                return newIdentifier
            } catch {
                dprint("保存设备ID失败, Error: \(error)")
                return nil
            }
        } catch {
            dprint("读取设备ID失败, Error: \(error)")
            return nil
        }
    }
    
    var decimal: Decimal {
        Decimal(stringLiteral: self)
    }
    
    var characterSet: CharacterSet {
        CharacterSet(charactersIn: self)
    }
    
    /// 拼接冒号并返回
    var withColon: String {
        self + ": "
    }
    
    /// 如果不包含指定字符串则拼接
    /// - Parameter string: 指定字符串
    /// - Returns: 新的字符串
    func appendingIfNeeded(_ anyString: any StringProtocol) -> String {
        let contains: Bool
        if #available(iOS 16.0, *) {
            contains = ranges(of: anyString).isEmpty
        } else {
            contains = ranges(of: anyString.description).isEmpty
        }
        return contains ? appending(anyString) : self
    }
    
    /// 返回指定个数的头部子字符串
    /// - Parameter characterCount: 字符个数
    /// - Returns: 子字符串
    func first(_ characterCount: Int) -> Substring {
        guard characterCount <= count else { return "" }
        let tail = count - characterCount
        return dropLast(tail)
    }
    
    /// 返回指定个数的尾部子字符串
    /// - Parameter characterCount: 字符个数
    /// - Returns: 子字符串
    func last(_ characterCount: Int) -> Substring {
        guard characterCount <= count else { return "" }
        let head = count - characterCount
        return dropFirst(head)
    }
    
	func indices(of occurrence: String) -> [Int] {
		var indices: [Int] = []
		var position = startIndex
		while let range = range(of: occurrence, range: position..<endIndex) {
			let i = distance(from: startIndex, to: range.lowerBound)
			indices.append(i)
			let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
			guard let after = index(range.lowerBound, offsetBy: offset, limitedBy: endIndex) else {
				break
			}
			position = index(after: after)
		}
		return indices
	}
	func ranges(of searchString: String) -> [Range<String.Index>] {
		let _indices = indices(of: searchString)
		let count = searchString.count
		return _indices.map {
			index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0 + count)
		}
	}
	func nsRanges(of searchString: String) -> [NSRange] {
		ranges(of: searchString).map { $0.nsRange(in: self) }
	}
}
// MARK: - __________ Verification __________

enum StringType {
    /// 中国手机号
    case cellphoneNumber
    /// 邮箱地址
    case emailAddress
    /// 身份证号
    case identityCardNumber
    /// 正整数
    case number
    /// 小数
    case decimalNumber
    /// 密码
    case password(regex: String)
    
    private var regex: String {
        switch self {
        case .cellphoneNumber:
            return #"^1[3-9]\d{9}$"#
        case .emailAddress:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        case .identityCardNumber:
            return #"^[1-9]\d{5}(?:18|19|20)\d{2}(?:0[1-9]|10|11|12)(?:0[1-9]|[1-2]\d|30|31)\d{3}[\dXx]$"#
        case .number:
            return #"^[1-9]\d*|0$"#
        case .decimalNumber:
            return "^([0-9]{1,}[.][0-9]*)$"
        case .password(let regex):
            return regex
        }
    }
    
    func evaluate(_ target: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: target)
    }
}

extension String {
    
    /// 用于唯一标记设备(❌,不插卡的手机获取的值为空),是否能上架App Store还有待测试
    static var markMACAddress: String {
        
        func getMACAddressFromIPv6(ip: String) -> String{
            let IPStruct = IPv6Address(ip)
            if(IPStruct == nil){
                return ""
            }
            let extractedMAC = [
                (IPStruct?.rawValue[8])! ^ 0b00000010,
                IPStruct?.rawValue[9],
                IPStruct?.rawValue[10],
                IPStruct?.rawValue[13],
                IPStruct?.rawValue[14],
                IPStruct?.rawValue[15]
            ]
            let str = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", extractedMAC[0] ?? 00,
                extractedMAC[1] ?? 00,
                extractedMAC[2] ?? 00,
                extractedMAC[3] ?? 00,
                extractedMAC[4] ?? 00,
                extractedMAC[5] ?? 00)
            return str
        }
        
        func getAddress() -> String? {
            var address: String?

            // Get list of all interfaces on the local machine:
            var ifaddr: UnsafeMutablePointer<ifaddrs>?
            guard getifaddrs(&ifaddr) == 0 else { return nil }
            guard let firstAddr = ifaddr else { return nil }

            // For each interface ...
            for ifptr in Swift.sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
                let interface = ifptr.pointee
                
                // Check IPv6 interface:
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET6) {
                    // Check interface name:
                    let name = String(cString: interface.ifa_name)
                    if name.contains("ipsec") {
                        print("接口名字:", name)
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        let ipv6addr = IPv6Address(address ?? "::")
                        if(ipv6addr?.isLinkLocal ?? false){
                            return address
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)

            return address
        }
        
        let address = getAddress()
        let macAddress = getMACAddressFromIPv6(ip: address ?? "")
        return macAddress
    }
    
    func isValid(_ stringType: StringType) -> Bool {
        stringType.evaluate(self)
    }
    
	static var randomUUID: String {
        UUID.new.uuidString
	}
	
	func isValid(for characterSet: CharacterSet) -> Bool {
		false
	}
	
    var cfString: CFString {
        self as CFString
    }
    
	var trimmed: String {
		trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	var isEmptyString: Bool {
		trimmed.isEmpty
	}
    
    var isNotEmptyString: Bool {
        !isEmptyString
    }
	
	var isValidString: Bool {
		!isEmptyString
	}
	
	/// 判断字符串是否满足字符集中的字符(严格匹配)
	/// - Parameters:
	///   - characterSet: 匹配的字符集
	///   - options: 匹配选项
	/// - Returns: 检查结果
	func match(_ characterSet: CharacterSet, options: CompareOptions = []) -> Bool {
		rangeOfCharacter(from: characterSet.inverted, options: options) == .none
	}
	
	/// 字符串中是否包含指定字符集中的字符
	/// - Parameters:
	///   - characterSet: 匹配的字符集
	///   - options: 匹配选项
	/// - Returns: 检查结果
	func containsCharacter(in characterSet: CharacterSet, options: CompareOptions = []) -> Bool {
		rangeOfCharacter(from: characterSet, options: options) != .none
	}
	
	/// 移除不需要的字符
	/// - Parameter notAllowed: 不需要的字符集 | 可以用正常字符集反向获取到
	mutating func removeCharacters(in notAllowed: CharacterSet) {
		unicodeScalars.removeAll { scalar in
			notAllowed.contains(scalar)
		}
	}
	
	/// 移除不需要的字符 | 返回新字符串
	/// - Parameter notAllowed: 不需要的字符集 | 可以用正常字符集反向获取到
	/// - Returns: 处理过的字符串
	func removingCharacters(in notAllowed: CharacterSet) -> String {
		var copy = self
		copy.removeCharacters(in: notAllowed)
		return copy
	}
	
	var validStringOrNone: String? {
		isEmptyString ? .none : self
	}
}

extension Substring {
	
	var string: String {
		String(self)
	}
}

extension String {
	
	subscript (_ range: ClosedIntRange) -> String {
		get {
			guard range.upperBound < count else {
				return ""
			}
			let start = index(startIndex, offsetBy: range.lowerBound)
			let end = index(startIndex, offsetBy: range.upperBound)
			return self[start ... end].string
		}
		set {
			guard range.upperBound < count else {
				return
			}
			let start = index(startIndex, offsetBy: range.lowerBound)
			let end = index(startIndex, offsetBy: range.upperBound)
			replaceSubrange(start ... end, with: newValue)
		}
	}
	
	subscript (_ range: PartialRangeFrom<Int>, head head: String = "") -> String {
		get {
			guard range.lowerBound < count else {
				return ""
			}
			let start = index(startIndex, offsetBy: range.lowerBound)
			return head + self[start...].string
		}
		set {
			guard range.lowerBound < count else {
				return
			}
			let start = index(startIndex, offsetBy: range.lowerBound)
			replaceSubrange(start..., with: newValue)
		}
	}
	
	subscript (_ range: PartialRangeThrough<Int>, tail tail: String = "") -> String {
		get {
			guard range.upperBound < count else {
				return self
			}
			let index = index(startIndex, offsetBy: range.upperBound)
			let cropped = self[...index].string
			return cropped + (count > cropped.count ? tail : "")
		}
		set {
			guard range.upperBound < count else {
				return
			}
			let index = index(startIndex, offsetBy: range.upperBound)
			replaceSubrange(...index, with: newValue)
		}
	}
}

// MARK: - 转换
extension String {
    
    /// SwifterSwift: Check if string contains one or more emojis.
    ///
    ///        "Hello 😀".containEmoji -> true
    ///
    var containsEmoji: Bool {
        // http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x1F1E6...0x1F1FF, // Regional country flags
                0x2600...0x26FF, // Misc symbols
                0x2700...0x27BF, // Dingbats
                0xE0020...0xE007F, // Tags
                0xFE00...0xFE0F, // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                127_000...127_600, // Various asian characters
                65024...65039, // Variation selector
                9100...9300, // Misc items
                8400...8447: // Combining Diacritical Marks for Symbols
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /// 中文->拼音. "中国"->"zhong guo"
    var pinyin: String {
        let pointer = NSMutableString(string: self)
        CFStringTransform(pointer, nil, kCFStringTransformToLatin, false)
        CFStringTransform(pointer, nil, kCFStringTransformStripDiacritics, false)
        return String(pointer)
    }
    
    var stringFromBase64: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    var base64: String {
        Data(utf8).base64EncodedString()
    }
    
    /// 以空(\0)结尾的ASCII二进制
    var nullTerminatedASCII: Data? {
        cString(using: .ascii).map {
            Data(bytes: $0, count: $0.count)
        }
    }
    
    /// 转换为utf8编码的二进制数据
    /// 注: 其中系统属性utf8CString已经在尾部拼接上了\0(null-terminated)
    var nullTerminatedUTF8: Data {
        let bytes = utf8CString.map(UInt8.init)
        return Data(bytes)
    }
    
    var utf8Encoded: Data? {
        data(using: .utf8)
    }
    
    /// 将Base64编码过后的字符串转换成Image
    var imageFromBase64EncodedString: UIImage? {
        guard let dataFromBase64EncodedString else { return nil }
        return UIImage(data: dataFromBase64EncodedString)
    }
    
    /// 将Base64编码过后的字符串转换成二进制
    var dataFromBase64EncodedString: Data? {
        Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
    
    var url: URL? {
        URL(string: self)
    }
}
