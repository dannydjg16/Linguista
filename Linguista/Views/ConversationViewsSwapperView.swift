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
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack {
            SettingsView(languageToTranslate: $languageToTranslate)
            
            NavigationView {

                TabView(selection: $innerSelection) {
                    ChatView(messagingViewModel: messagingViewModel, languageToTranslate: $languageToTranslate, innerSelection: $innerSelection)
                        .tag(0)
                        .padding(.bottom, 40)

                    
                    TextMessagingView(messagingViewModel: messagingViewModel, languageToTranslate: $languageToTranslate)
                        .tag(1)
                        .padding(.bottom, 40)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }

    }
}
