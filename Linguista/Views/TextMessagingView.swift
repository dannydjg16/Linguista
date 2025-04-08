//
//  TextMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TextMessagingView: View {
    
    @ObservedObject var conversationViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var languageToTranslate: Int
    
    var body: some View {
        VStack{
            
            MessageListView(conversationViewModel: conversationViewModel)
                .background(Color.white)
                .cornerRadius(10)
            
            MessageInputView(
                languageToTranslate: $languageToTranslate,
                conversationViewModel: conversationViewModel,
                speechRecognizer: speechRecognizer
            )
        }
    }
}

struct TextMessagingView_Previews: PreviewProvider {
    @State static var languageToTranslate = 1
    static var previews: some View {
        TextMessagingView(conversationViewModel: ConversationViewModel(), languageToTranslate: $languageToTranslate)
    }
}
