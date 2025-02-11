//
//  ConversationViewsSwapperView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/5/25.
//

import Foundation
import SwiftUI

struct ConversationViewsSwapperView: View {
    
    @StateObject private var messagingViewModel = ConversationViewModel()
    @State private var innerSelection = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $innerSelection) {
                
                ChatView(messagingViewModel: messagingViewModel)
                    .tag(0)
                
                
                TextMessagingView(messagingViewModel: messagingViewModel)
                    .tag(1)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
