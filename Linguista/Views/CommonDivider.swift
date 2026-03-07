//
//  CommonDivider.swift
//  Linguista
//
//  Created by Daniel Grant on 3/6/26.
//

import SwiftUI

struct CommonDivider: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Divider()
            .frame(height: 1)
            .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
            .padding([.leading, .trailing])
    }
}
