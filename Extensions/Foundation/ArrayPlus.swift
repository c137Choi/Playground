//
//  ArrayPlus.swift
//
//  Created by Choi on 2022/10/21.
//

import Foundation

extension Array {
    
    init(@ArrayBuilder<Element> _ itemsBuilder: () -> Self) {
        self.init(itemsBuilder())
    }
    
    public mutating func refill(@ArrayBuilder<Element> _ builder: () -> [Element]) {
        refill(builder())
    }
    
    public mutating func refill(_ newElements: Element...) {
        refill(newElements)
    }
    
    public mutating func refill(_ newElements: [Element]) {
        removeAll()
        append(contentsOf: newElements)
    }
    
    public mutating func append(@ArrayBuilder<Element> _ builder: () -> [Element]) {
        let elements = builder()
        append(contentsOf: elements)
    }
    
    /// 对Index求余,得出有效Index之后获取元素
    subscript (modElement inputIndex: Self.Index) -> Element? {
        guard let modIndex = indices[modIndex: inputIndex] else { return nil }
        return self[modIndex]
    }
    
    /// 循环访问数组元素 | 如: 利用下标循环访问数组的元素
    subscript (cycledElement inputIndex: Self.Index) -> Element? {
        guard let cycledIndex = indices[cycledIndex: inputIndex] else { return nil }
        return self[cycledIndex]
    }
    
    /// 拼接元素并返回最新的数组
    /// - Parameter element: 新元素
    /// - Returns: 拼接后的数组
    public func appending(_ element: Element) -> [Element] {
        var newArray = self
        newArray.append(element)
        return newArray
    }
    
    /// 拼接Sequence并返回最新的数组
    /// - Parameter newElements: 元素Sequence
    /// - Returns: 拼接后的数组
    public func appending<S>(contentsOf newElements: S) -> [Element] where Element == S.Element, S : Sequence {
        var newArray = self
        newArray.append(contentsOf: newElements)
        return newArray
    }
    
    /// 拼接元素
    /// - Parameter element: Optional<Element>类型元素, 有值时才拼接
    public mutating func append(_ element: Element?) {
        if let element {
            append(element)
        }
    }
    
    /// 替换指定位置的元素
    /// - Parameters:
    ///   - index: 元素Index
    ///   - newElement: 新元素
    public mutating func safeReplace(elementAt index: Index, with newElement: Element) {
        guard isValidIndex(index) else { return }
        guard let subrangeEnd = self.index(index, offsetBy: 1, limitedBy: endIndex) else { return }
        replaceSubrange(index..<subrangeEnd, with: [newElement])
    }
    
    /// 安全移除指定位置的元素
    /// - Parameter index: 元素位置
    /// - Returns: 如果存在,则返回被移除的元素
    public mutating func safeRemove(at index: Int) -> Element? {
        guard isValidIndex(index) else { return nil }
        return remove(at: index)
    }
    
    public init(generating elementGenerator: (Int) -> Element, count: Int) {
        self = (0..<count).map(elementGenerator)
    }
    
    public init(generating elementGenerator: () -> Element, count: Int) {
        self = (0..<count).map { _ in
            elementGenerator()
        }
    }
}

extension Array {
    
    public static func * (lhs: Double, rhs: Self) -> Element? { rhs * lhs }
    public static func * (lhs: Self, rhs: Double) -> Element? {
        (lhs.indices * rhs).flatMap { index in
            lhs.element(at: index)
        }
    }
    
    public static func + (lhs: Self, rhs: Element) -> [Element] {
        lhs.appending(rhs)
    }
}

// MARK: - Equatable Array
extension Array where Element: Equatable {
    
    @discardableResult
    /// 替换指定元素
    /// - Parameter newElement: 新元素
    /// - Returns: 是否替换成功
    public mutating func replace(
        with newElement: Element,
        if prediction: (_ old: Element, _ new: Element) -> Bool = { $0 == $1 }
    ) -> Bool {
        let index = firstIndex { oldElement in
            prediction(oldElement, newElement)
        }
        if let index {
            let range = index..<index + 1
            let updated = [newElement]
            replaceSubrange(range, with: updated)
            return true
        } else {
            append(newElement)
            return false
        }
    }
    
    @discardableResult
    /// 移除指定元素
    /// - Parameter element: 要移除的元素
    /// - Returns: 更新后的数组
    public mutating func remove(_ element: Element) -> Array {
        if let foundIndex = firstIndex(of: element) {
            remove(at: foundIndex)
        }
        return self
    }
}

// MARK: - Hashable Array
extension Array where Element : Hashable {
    
    mutating func appendUnique<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence {
        newElements.forEach { element in
            appendUnique(element)
        }
    }
    
    /// 添加唯一的元素
    /// - Parameter newElement: 遵循Hashable的元素
    mutating func appendUnique(_ newElement: Element) {
        let isNotUnique = contains { element in
            element.hashValue == newElement.hashValue
        }
        guard !isNotUnique else { return }
        append(newElement)
    }
    
    /// 合并唯一的元素 | 可用于reduce
    /// - Parameters:
    ///   - lhs: 数组
    ///   - rhs: 要添加的元素
    /// - Returns: 结果数组
    static func +> (lhs: Self, rhs: Element) -> Self {
        var result = lhs
        result.appendUnique(rhs)
        return result
    }
    
    /// 合并数组
    /// - Parameters:
    ///   - lhs: 原数组
    ///   - rhs: 新数组
    /// - Returns: 合并唯一元素的数组
    static func +> (lhs: Self, rhs: Self) -> Self {
        rhs.reduce(lhs, +>)
    }
}

extension Array where Element: Numeric {
    
    /// 向量 * 矩阵
    static func * (vector: [Element], matrix: [[Element]]) -> [Element] {
        /// 确保向量数组和矩阵个数匹配
        guard vector.count == matrix.count else { return .empty }
        /// 内部的一维数组个数也必须匹配
        let innerArrayCountMatch = matrix.allSatisfy { array in
            array.count == vector.count
        }
        guard innerArrayCountMatch else { return .empty }
        var result: [Element] = []
        for row in 0..<vector.count {
            var resultElement: Element?
            for col in 0..<matrix.count {
                /// 乘积
                let product = matrix[col][row] * vector[col]
                /// 累加
                if let temResult = resultElement {
                    resultElement = temResult + product
                } else {
                    /// 赋初值
                    resultElement = product
                }
            }
            if let resultElement {
                result.append(resultElement)
            }
        }
        return result
    }
}

// MARK: - 数据交换
extension Array {
    /// 交换数组中两个元素的位置
    /// - Parameters:
    ///   - index1: 第一个元素的索引
    ///   - index2: 第二个元素的索引
    /// - Returns: 交换元素后的新数组
    func exchangingElements(at index1: Int, with index2: Int) -> [Element] {
        guard index1 != index2,
              index1 >= 0, index1 < count,
              index2 >= 0, index2 < count else {
            return self
        }
        var newArray = self
        newArray.swapAt(index1, index2)
        return newArray
    }
    
    /// 交换数组中当前元素与前一个元素的位置（如果是第一个元素，则与最后一个元素交换）
    /// - Parameter index: 当前元素的索引
    /// - Returns: 交换元素后的新数组
    func exchangingWithPrevious(at index: Int) -> [Element] {
        guard isNotEmpty else { return self }
        let previousIndex = index == 0 ? count - 1 : index - 1
        return exchangingElements(at: index, with: previousIndex)
    }
}
