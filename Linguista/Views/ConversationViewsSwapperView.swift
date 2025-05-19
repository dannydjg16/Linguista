//
//  ConversationViewsSwapperView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/5/25.
//

import Foundation
import SwiftUI

struct ConversationViewsSwapperView: View {
    
    @State private var chatTabViewSelectedValue = 0
    
    var body: some View {
        VStack {
            SettingsView(chatTabViewSelectedValue: $chatTabViewSelectedValue)
            
            NavigationView {
                TabView(selection: $chatTabViewSelectedValue) {
                    TextMessagingView()
                        .tag(0)
                        .padding(.bottom, 40)
                    
                    ChatView(chatTabViewSelectedValue: $chatTabViewSelectedValue)
                        .tag(1)
                        .padding(.bottom, 40)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .onChange(of: chatTabViewSelectedValue) {
                    print("Tab changed to: \(chatTabViewSelectedValue)")
                }
            }
        }
    }
}
