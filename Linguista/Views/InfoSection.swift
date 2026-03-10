//
//  InfoSection.swift
//  Linguista
//
//  Created by Daniel Grant on 3/8/26.
//
import SwiftUI

struct InfoSection<Content: View>: View {
    let title: String
    let content: () -> Content
    @Environment(\.colorScheme) var colorScheme

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack {

            HStack {
                Text("\(title):")
                    .padding(.leading)
                    .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                    .italic()
                Spacer()
            }

            content()

            CommonDivider()
        }
    }
}
