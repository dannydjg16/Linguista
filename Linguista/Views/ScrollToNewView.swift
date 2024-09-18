//
//  ScrollToNewView.swift
//  Linguista
//
//  Created by Daniel Grant on 9/16/24.
//

import SwiftUI

struct ScrollToNewView: View {
    @State private var messages: [String] = ["Hello", "How are you?", "I'm fine, thank you!"]
    @State private var newMessage: String = ""
    
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var currentMessage = ""
    @State private var languageToTranslate = 1
    @State private var textEditorHeight: CGFloat = 20
    
    
    var body: some View {
        VStack {
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
            
            // Text field and send button
            HStack {
                TextField("Type a message", text: $currentMessage)
                    .frame(height: textEditorHeight)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                    .cornerRadius(8)
                
                Button(action: {
                    let messages = [Message(role: "system", content: "Translate \(Utilities.getLanguageName(by: languageToTranslate)) into english, or english to \(Utilities.getLanguageName(by: languageToTranslate)) based on what word is provided. The response should contain only the direct translation and it should be written in the latin alphabet"), Message(role: "user", content: "\(currentMessage)")]
                    
                    let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
                    
                    messagingViewModel.sendMessage(completionRequest: dataModel)
                    
                    currentMessage = ""
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
    
    private func sendMessage() {
        if !newMessage.isEmpty {
            messages.append(newMessage)
            newMessage = ""
        }
    }
}

struct ScrollToNewView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollToNewView()
    }
}
