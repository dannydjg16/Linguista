//
//  ChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/2/25.
//


import Foundation
import SwiftUI

struct ChatView: View {
    
    @ObservedObject var messagingViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack{
            
            Text("CHAT VIEW")
            LanguagePickerView(languageToTranslate: $languageToTranslate)
            
            MessageListView(messagingViewModel: messagingViewModel)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            
            MessageInputView(
                languageToTranslate: $languageToTranslate,
                messagingViewModel: messagingViewModel,
                speechRecognizer: speechRecognizer
            )
            .padding()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(messagingViewModel: ConversationViewModel())
    }
}
