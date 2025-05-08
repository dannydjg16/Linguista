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
    @State private var innerSelection = 0
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack {
            SettingsView(languageToTranslate: $languageToTranslate, conversationViewModel: conversationViewModel, innerSelection: $innerSelection)
            
            NavigationView {

                TabView(selection: $innerSelection) {
                    TextMessagingView(conversationViewModel: conversationViewModel, languageToTranslate: $languageToTranslate)
                        .tag(0)
                        .padding(.bottom, 40)
                    
                    ChatView(conversationViewModel: conversationViewModel, languageToTranslate: $languageToTranslate, innerSelection: $innerSelection)
                        .tag(1)
                        .padding(.bottom, 40)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .onChange(of: innerSelection) {
                    print("Tab changed to: \(innerSelection)")
                }
            }
        }
    }
}
