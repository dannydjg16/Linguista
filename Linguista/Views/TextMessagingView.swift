//
//  TextMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TextMessagingView: View {
    
    @ObservedObject var messagingViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var languageToTranslate: Int
    
    var body: some View {
        VStack{
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

struct TextMessagingView_Previews: PreviewProvider {
    @State static var languageToTranslate = 1
    static var previews: some View {
        TextMessagingView(messagingViewModel: ConversationViewModel(), languageToTranslate: $languageToTranslate)
    }
}
