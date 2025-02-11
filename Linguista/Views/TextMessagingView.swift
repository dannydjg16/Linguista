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
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack{
            
            Text("SPOKEN MESSAGING VIEW")
            LanguagePickerView(languageToTranslate: $languageToTranslate)
            
            BackAndForthChatView(messagingViewModel: messagingViewModel)
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
    static var previews: some View {
        TextMessagingView(messagingViewModel: ConversationViewModel())
    }
}
