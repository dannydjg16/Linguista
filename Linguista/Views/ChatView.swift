//
//  ChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/2/25.
//


import Foundation
import SwiftUI

struct ChatView: View {
    
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            SettingsView(selectedTab: $selectedTab)
            TalkingChatView()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(selectedTab: .constant(1))
    }
}
