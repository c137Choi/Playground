//
//  TypeAlias.swift
//  ExtensionDemo
//
//  Created by Choi on 2022/6/28.
//  Copyright © 2022 Choi. All rights reserved.
//

import UIKit

public typealias UIViewArray = [UIView]
public typealias Byte = UInt8
public typealias UUIDArray = Array<UUID>
public typealias IntSet = Set<Int>
public typealias UUIDSet = Set<UUID>
public typealias ClosedIntRange = ClosedRange<Int>
public typealias ClosedIntRangeArray = Array<ClosedIntRange>
public typealias ClosedDoubleRange = ClosedRange<Double>
public typealias IndexPathSet = Set<IndexPath>
public typealias SimpleCallback = () -> Void
public typealias ThrowsSimpleCallback = () throws -> Void
public typealias CompletedCallback = (Swift.Error?) -> Void
public typealias TouchesWithEvent = (Set<UITouch>, UIEvent?)
