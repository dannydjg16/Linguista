//
//  ConversationViewsSwapperView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/5/25.
//

import Foundation
import SwiftUI

struct ConversationViewsSwapperView: View {
    
    @StateObject private var conversationViewModel = ConversationViewModel()
    @State private var innerSelection = 1
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack {
            SettingsView(languageToTranslate: $languageToTranslate, conversationViewModel: conversationViewModel, innerSelection: $innerSelection)
            
            NavigationView {

                TabView(selection: $innerSelection) {
                    ChatView(conversationViewModel: conversationViewModel, languageToTranslate: $languageToTranslate, innerSelection: $innerSelection)
                        .tag(0)
                        .padding(.bottom, 40)

                    
                    TextMessagingView(conversationViewModel: conversationViewModel, languageToTranslate: $languageToTranslate)
                        .tag(1)
                        .padding(.bottom, 40)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
    }
}
