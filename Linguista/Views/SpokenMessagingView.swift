//
//  SpokenMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/11/24.
//

import Foundation
import SwiftUI

struct SpokenMessagingView: View {
    
    @ObservedObject var messagingViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var languageToTranslate = 1
    
    var body: some View {
        VStack{
            
            Text("SPOKEN MESSAGING VIEW")
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

struct SpokenMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        SpokenMessagingView(messagingViewModel: ConversationViewModel())
    }
}
