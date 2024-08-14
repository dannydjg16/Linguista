//
//  QuickTranslateView.swift
//  Linguista
//
//  Created by Daniel Grant on 8/9/24.
//

import Foundation
import SwiftUI

struct QuickTranslateView: View {
    @State private var translationText = "Translation Text"
    @State private var isPlaceholderVisible = true
    @State private var translationResult = "See Translation"
    @State private var isPlaceholderResultVisible = true
    @State private var languageOne = 1
    @State private var languageTwo = 1
    

    
    var body: some View {
        
        List{
            Section{
                Picker("Translate Language:", selection: $languageOne) {
                    Text("Eng").tag(1)
                    Text("Two").tag(2)
                    Text("Three").tag(3)
                }
                .pickerStyle(MenuPickerStyle())
                
                TextEditor(text: $translationText)
                    .frame(height: 200)
                    .border(Color.white, width: 1)
                    .foregroundColor(isPlaceholderVisible ? Color.gray : Color.primary)
                    .onTapGesture {
                        if isPlaceholderVisible {
                            translationText = "" // Clear the placeholder text when the user taps
                            isPlaceholderVisible = false
                        }
                    }

            }

            Section{
               HStack{
                    Spacer()
                    
                    Button(action: {
                        let messages = [Message(role: "system", content: "translate"), Message(role: "user", content: "\(translationText)")]
                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
                        //viewModel.fetchCompletion(completionRequest: dataModel)
                    }) {
                        Text("Translate")
                            //.padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    .frame(width: 150)
                   
                   Spacer()
                }
             }

            Section{
                Picker("Translate to:", selection: $languageTwo) {
                    Text("One").tag(1)
                    Text("Two").tag(2)
                    Text("Three").tag(3)
                }
                .pickerStyle(MenuPickerStyle())
                
                TextEditor(text: $translationResult)
                    .frame(height: 200)
                    .border(Color.white, width: 1)
                    .foregroundColor(isPlaceholderResultVisible ? Color.gray : Color.primary)
                    .onTapGesture {
                        if isPlaceholderResultVisible {
                            translationResult = "" // Clear the placeholder text when the user taps
                            isPlaceholderVisible = false
                        }
                    }
            }
        }
        
    }
}

struct QuickTranslateView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTranslateView()
    }
}
