//
//  TextMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TextMessagingView: View {
    
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var languageToTranslate: Int
    
    var body: some View {
        VStack{
            MessageListView()
            
            MessageInputView(
                languageToTranslate: $languageToTranslate,
                speechRecognizer: speechRecognizer
            )
        }
    }
}

struct TextMessagingView_Previews: PreviewProvider {
    @State static var languageToTranslate = 1
    static var previews: some View {
        TextMessagingView(languageToTranslate: $languageToTranslate)
            .environmentObject(ConversationViewModel())
    }
}
