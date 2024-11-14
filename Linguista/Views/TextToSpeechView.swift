//
//  TextToSpeechView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/14/24.
//

import Foundation
import SwiftUI
import AVFoundation

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
