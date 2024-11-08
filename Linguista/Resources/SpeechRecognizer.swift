//
//  SpeechRecognizer.swift
//  Linguista
//
//  Created by Daniel Grant on 11/7/24.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    @Published var transcribedText = ""
    @Published var isRecording = false
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    // Function to request permission to use speech recognition
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Permission granted")
                default:
                    print("Permission denied")
                }
            }
        }
    }

    // Function to start listening and transcribing speech
    func startTranscribing() {
        // Ensure previous tasks are stopped
        stopTranscribing()

        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Setup recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopTranscribing()
            }
        }

        // Setup audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    // Function to stop transcribing and reset the session
//    func stopTranscribing() {
//        audioEngine.stop()
//        recognitionRequest?.endAudio()
//        recognitionTask?.cancel()
//        recognitionRequest = nil
//        recognitionTask = nil
//    }
    
    func stopTranscribing() {
        // Stop the audio engine
        audioEngine.stop()
        
        // Remove the input node tap
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End the audio session
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Reset recognitionRequest and recognitionTask
        recognitionRequest = nil
        recognitionTask = nil
    }
}
