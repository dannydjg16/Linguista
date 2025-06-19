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
    @Binding var chatTabViewSelectedValue: Int
    
    var body: some View {
        VStack {
            TalkingChatView()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    @State static var chatTabViewSelectedValue = 1
    static var previews: some View {
        ChatView(chatTabViewSelectedValue: $chatTabViewSelectedValue)
            .environmentObject(ConversationViewModel())
    }
}
