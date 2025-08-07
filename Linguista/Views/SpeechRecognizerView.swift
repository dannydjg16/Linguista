//
//  SpeechRecognizerView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/7/24.
//

import Foundation
import SwiftUI

struct SpeechRecognizerView: View {
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        VStack {
            
            Button(action: toggleRecording) {
                Text(speechRecognizer.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(speechRecognizer.isRecording ? Color.red : Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            speechRecognizer.requestAuthorization()
        }
    }
    
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            speechRecognizer.startTranscribing()
        }
        speechRecognizer.isRecording.toggle()
    }
}

struct SpeechRecognizerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechRecognizerView()
    }
}
