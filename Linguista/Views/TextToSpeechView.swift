//
//  TextToSpeechView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/14/24.
//

import SwiftUI
import AVFoundation

struct TextToSpeechView: View {
    @StateObject private var textToSpeech = TextToSpeechA()
    //@State private var textToSpeak = "Hello, my name is"
    @State private var textToSpeak = "سلام، چطور هستید؟"
    @State private var selectedLanguage = "fa-IR"
    //@State private var selectedLanguage = "en-US"
    let languages = ["fa-IR": "Farsi", "en-US": "English (US)"]

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $textToSpeak)
                .frame(height: 200)
                .padding()
                .border(Color.gray, width: 1)

            Picker("Language", selection: $selectedLanguage) {
                ForEach(languages.keys.sorted(), id: \.self) { key in
                    Text(languages[key]!).tag(key)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Button(action: {
                textToSpeech.speak(text: textToSpeak, language: selectedLanguage)
            }) {
                Text("Speak Text")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

class TextToSpeechA: ObservableObject {
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(text: String, language: String = "fa-IR") {
        // Stop any current speech before starting new speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesizer.speak(utterance)
    }
}
