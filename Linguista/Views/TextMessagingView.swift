//
//  TextMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TextMessagingView: View {
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack{
            MessageListView()
            
            MessageInputView(
                speechRecognizer: speechRecognizer
            )
        }
    }
}

struct TextMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        TextMessagingView()
            .environmentObject(ConversationViewModel())
    }
}
