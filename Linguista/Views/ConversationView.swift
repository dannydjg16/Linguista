//
//  ConversationView.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation
import SwiftUI

struct ConversationView: View {
    
    @StateObject private var messagingViewModel = ConversationViewModel()
    @State private var currentMessage = ""
    @State private var languageToTranslate = 1
    @State private var textEditorHeight: CGFloat = 20
    
    var body: some View {
        VStack{
            Section{
                
                Picker("Language: ", selection: $languageToTranslate) {
                    ForEach(popularLanguageObjects){ language in
                        Text(language.name).tag(language.id)
                        
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 10)
                
            }
            .background(Color.brown.opacity(0.15))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.brown.opacity(0.15), lineWidth: 2))
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach($messagingViewModel.messages, id: \.id) { $message in
                            
                            HStack {
                                
                                if message.isSentByUser {
                                    Spacer()
                                    
                                    Text(message.message.content)
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                                    
                                } else {
                                    Text(message.message.content)
                                        .padding()
                                        .background(Color.brown.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                .onChange(of: $messagingViewModel.messages.count) {
                    // Scroll to the last message when new messages are added
                    if let lastIndex = $messagingViewModel.messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type a message", text: $currentMessage)
                    .frame(height: textEditorHeight)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                    .cornerRadius(8)
                
                Button(action: {
                    
                    if !currentMessage.isEmpty {
                        let messages = [Message(role: "system", content: "Pretend you are having a conversation as if you are teaching an English speaking person \(Utilities.getLanguageName(by: languageToTranslate)). Respond in \(Utilities.getLanguageName(by: languageToTranslate)) but output the response in the latin alphabet."),
                                        Message(role: "user", content: "\(currentMessage)")]
                        
                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 30, topP: 1)
                        
                        messagingViewModel.sendMessage(completionRequest: dataModel)
                        
                        currentMessage = ""
                    }
                    
                }) {
                    Text("Send")
                        .bold()
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
        }
    }
}


struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
