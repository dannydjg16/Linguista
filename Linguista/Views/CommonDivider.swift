//
//  CommonDivider.swift
//  Linguista
//
//  Created by Daniel Grant on 3/6/26.
//

import SwiftUI

struct CommonDivider: View {
    
    @Environment(\.colorScheme) var colorScheme
    var height: CGFloat = 1

    var body: some View {
        Divider()
            .frame(height: height)
            .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
            .padding([.leading, .trailing])
    }
}
