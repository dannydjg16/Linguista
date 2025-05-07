//
//  ChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/2/25.
//


import Foundation
import SwiftUI

struct ChatView: View {
    
    @ObservedObject var conversationViewModel: ConversationViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var languageToTranslate: Int
    @Binding var innerSelection: Int
    
    var body: some View {
        VStack {
            BackAndForthChatView(conversationViewModel: conversationViewModel)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    @State static var languageToTranslate = 1
    @State static var innerSelection = 1
    static var previews: some View {
        ChatView(conversationViewModel: ConversationViewModel(), languageToTranslate: $languageToTranslate, innerSelection: $innerSelection)
    }
}
