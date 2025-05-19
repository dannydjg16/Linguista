//
//  ChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/2/25.
//


import Foundation
import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var languageToTranslate: Int
    @Binding var chatTabViewSelectedValue: Int
    
    var body: some View {
        VStack {
            BackAndForthChatView()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    @State static var languageToTranslate = 1
    @State static var chatTabViewSelectedValue = 1
    static var previews: some View {
        ChatView(languageToTranslate: $languageToTranslate, chatTabViewSelectedValue: $chatTabViewSelectedValue)
            .environmentObject(ConversationViewModel())
    }
}
