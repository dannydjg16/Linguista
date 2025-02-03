//
//  ChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/2/25.
//


import Foundation
import SwiftUI

struct ChatView: View {
    
    @StateObject private var messagingViewModel = ConversationViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack{
            
            LanguagePickerView(languageToTranslate: $languageToTranslate)
            
            MessageListView(messagingViewModel: messagingViewModel)
                .padding()
                .background(Color.white)
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
