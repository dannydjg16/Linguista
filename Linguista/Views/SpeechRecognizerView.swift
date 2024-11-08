//
//  SpeechRecognizerView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/7/24.
//

import Foundation
import SwiftUI

struct SpeechRecognizerView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack {
            Text(speechRecognizer.transcribedText)
                .padding()
                .border(Color.gray, width: 1)
                .padding()

            Button(action: toggleRecording) {
                Text(speechRecognizer.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(speechRecognizer.isRecording ? Color.red : Color.green)
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
    }
}

struct SpeechRecognizerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechRecognizerView()
    }
}
