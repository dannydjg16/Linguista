//
//  WordFrameKey.swift
//  Linguista
//
//  Created by Daniel Grant on 3/24/26.
//

import SwiftUI

struct WordFrameKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]
    static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
