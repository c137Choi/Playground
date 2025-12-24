//
//  SwiftUIPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/3/3.
//  Copyright © 2021 Choi. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
private extension UIEdgeInsets {
    
    var swiftUIEdgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

@available(iOS 13.0, *)
struct SafeAreaInsetsKey: PreferenceKey, EnvironmentKey {
    
    static var defaultValue: EdgeInsets {
        UIApplication.keyWindow?.safeAreaInsets.swiftUIEdgeInsets ?? EdgeInsets()
    }
    
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

@available(iOS 13.0, *)
extension View {
    
    // MARK: - 获取 SafeAreaInsets
    func getSafeAreaInsets(_ safeInsets: Binding<EdgeInsets>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SafeAreaInsetsKey.self, value: proxy.safeAreaInsets)
            }
            .onPreferenceChange(SafeAreaInsetsKey.self) { value in
                safeInsets.wrappedValue = value
            }
        )
    }
    
    // MARK: - 打印 SafeAreaInsets
    func printSafeAreaInsets(id: String) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SafeAreaInsetsKey.self, value: proxy.safeAreaInsets)
            }
            .onPreferenceChange(SafeAreaInsetsKey.self) { value in
                print("\(id) insets:\(value)")
            }
        )
    }
}

// MARK: - 测试
@available(iOS 13.0, *)
struct TestGetSafeAreaInsets: View {
    
    @Environment(\.safeAreaInsets) private var globalInsets
    
    @State var safeAreaInsets = EdgeInsets()
    
    var body: some View {
        NavigationView {
            VStack {
                Color.blue
            }
        }
        .getSafeAreaInsets($safeAreaInsets)
        .printSafeAreaInsets(id: "NavigationView")
    }
}
