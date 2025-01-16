//
//  SpokenMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/11/24.
//

import Foundation
import SwiftUI

struct SpokenMessagingView: View {
    
    @StateObject private var messagingViewModel = ConversationViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var currentMessage = ""
    @State private var languageToTranslate = 1
    @State private var textEditorHeight: CGFloat = 20
    
    var body: some View {
        VStack{
            
            LanguagePickerView(languageToTranslate: $languageToTranslate)
            
            MessageListView(messagingViewModel: messagingViewModel)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            MessageInputView(
                            speechRecognizer: speechRecognizer,
                            languageToTranslate: $languageToTranslate,
                            messagingViewModel: messagingViewModel
                        )
                        .padding()
        }
    }
}

struct SpokenMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        SpokenMessagingView()
    }
}
