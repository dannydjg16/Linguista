//
//  TextToSpeechView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/14/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct TextToSpeechView: View {
    @StateObject private var textToSpeech = TextToSpeech()
    @State private var textToSpeak = ""

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $textToSpeak)
                .frame(height: 200)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
            
            Button(action: {
                textToSpeech.speak(text: textToSpeak)
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

class TextToSpeech: ObservableObject {
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        // Stop speaking any current speech before starting new speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fa-IR")
        speechSynthesizer.speak(utterance)
    }
}
