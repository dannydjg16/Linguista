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
    @State private var languageToTranslate = 2
    @State private var languageToTranslateTo = 1
    @StateObject var viewModel = MessageViewModel()
    

    
    var body: some View {

        
        List{
//            if let response = viewModel.completionResponse {
//                if let choices = response.choices {
//                    // Here, we modify the state property and use it to display the result
//                    Text(choices.map { $0.message.content }.joined(separator: " "))
//                        .onAppear {
//                            translationResult = choices.map { $0.message.content }.joined(separator: " ")
//                        }
//                } else {
//                    Text("No choices available")
//                }
//            } else {
//                Text("No response available")
//            }
            Section{
                Picker("Translate Language:", selection: $languageToTranslate) {
                    ForEach(popularLanguageObjects){ language in
                        Text(language.name).tag(language.id)
                    }
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
                        let messages = [Message(role: "system", content: "translate \(getLanguageName(by: languageToTranslate)) into \(getLanguageName(by: languageToTranslateTo)). Only respond using the latin alphabet"), Message(role: "user", content: "\(translationText)")]
                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
                        viewModel.fetchCompletion(completionRequest: dataModel)
                    }) {
                        Text("Translate")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                   
                   Spacer()
                }
             }

            Section{
                Picker("Translate to:", selection: $languageToTranslateTo) {
                    ForEach(popularLanguageObjects){ language in
                        Text(language.name).tag(language.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                TextEditor(text: $translationResult)
                    .frame(height: 200)
                    .border(Color.white, width: 1)
                    .foregroundColor(isPlaceholderResultVisible ? Color.black : Color.primary)
                    .onTapGesture {
                        if isPlaceholderResultVisible {
                            translationResult = "" // Clear the placeholder text when the user taps
                            isPlaceholderVisible = false
                        }
                    }
            }
        }
    }
    
    
    func getLanguageName(by id: Int) -> String {
        return popularLanguageObjects.first { $0.id == id }!.name
    }
}

struct QuickTranslateView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTranslateView()
    }
}
