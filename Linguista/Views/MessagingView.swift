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
    @State private var messagesList: [MessagingModel] = []
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
            
            Section{
                ScrollViewReader { scrollViewProxy in 
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach($messagesList, id: \.id) { $message in
                                
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
                    .onChange(of: messagesList) { _ in
                        // Scroll to the last message when new messages are added
                        if let lastIndex = messagesList.indices.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                            }
                        }
                    }
                }
                
                HStack {
                    TextEditor(text: $currentMessage)
                        .frame(height: textEditorHeight)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                    
                        .cornerRadius(8)
                        .onChange(of: currentMessage){
                            textEditorHeight = Utilities.recalculateHeight(height: textEditorHeight, text: currentMessage) // Adjust the height based on text changes
                        }
                    
                    Button(action: {
                        let messages = [Message(role: "system", content: "Translate \(Utilities.getLanguageName(by: languageToTranslate)) into english, or english to \(Utilities.getLanguageName(by: languageToTranslate)) based on what word is provided. The response should contain only the direct translation and it should be written in the latin alphabet"), Message(role: "user", content: "\(currentMessage)")]
                        
                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
                        
                        messagingViewModel.sendMessage(completionRequest: dataModel)
                        
                        currentMessage = ""
                        
                        messagesList = messagingViewModel.messages
                        
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
}

//struct MessagingView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessagingView()
//    }
//}
