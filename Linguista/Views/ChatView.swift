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
    @Binding var languageToTranslate: Int
    @Binding var innerSelection: Int
    
    var body: some View {
        VStack{
            //SettingsView(languageToTranslate: $languageToTranslate)
                        
            BackAndForthChatView(messagingViewModel: messagingViewModel, innerSelection: $innerSelection)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    @State static var languageToTranslate = 1
    @State static var innerSelection = 1
    static var previews: some View {
        ChatView(messagingViewModel: ConversationViewModel(), languageToTranslate: $languageToTranslate, innerSelection: $innerSelection)
    }
}
