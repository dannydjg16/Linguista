//
//  MessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation
import SwiftUI

struct MessagingView: View {
    
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var currentMessage = ""    

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    
                    ForEach($messagingViewModel.messages, id: \.id) { $message in
                        
                        HStack {
                            
                            if message.isSentByUser {
                                Spacer()
                                
                                Text(message.message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                            } else {
                                Text(message.message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Commented out for when we want dynamic language conversation. Will also need to update the latin alphabet part with a better prompt.
                    //let messages = [Message(role: "system", content: "translate \(getLanguageName(by: "farsi")) into \(getLanguageName(by: "english")). Only respond using the latin alphabet"), Message(role: "user", content: "\(currentMessage)")]
                    
                    // Commented out in case I every want to just test the implementation rather than specifics. Helped me once or twice so far.
                    //let messages = [Message(role: "system", content: "translate farsi into english. Only respond using the latin alphabet"), Message(role: "user", content: "gorbeh")]
                    
                    let messages = [Message(role: "system", content: "Translate farsi into english, or english to farsi based on what word is provided. Only respond using the latin alphabet"), Message(role: "user", content: "\(currentMessage)")]
                    
                    let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
                    
                    messagingViewModel.sendMessage(completionRequest: dataModel)
                    
                    currentMessage = ""
                    
                }) {
                    Text("Send")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct MessagingView_Previews: PreviewProvider {
    static var previews: some View {
        MessagingView()
    }
}
