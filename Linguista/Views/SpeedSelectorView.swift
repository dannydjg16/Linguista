//
//  SpeedSelectorView.swift
//  Linguista
//
//  Created by Daniel Grant on 12/30/24.
//

import Foundation
import SwiftUI

struct SpeedSelectorView: View {
    @Binding var playbackSpeed: Float
        //@Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            
            // Display current speed as a percentage
            Text("Current Playback Speed: \(Int(playbackSpeed * 100))%")
                .padding()
            
            Slider(value: $playbackSpeed, in: 0.5...1.4, step: 0.01)
                .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .bold()
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .padding()
    }
}

struct SpeedSelectorView_Previews: PreviewProvider {
    @State static var playbackSpeed: Float = 0.7
    static var previews: some View {
        SpeedSelectorView(playbackSpeed: $playbackSpeed)
    }
}
