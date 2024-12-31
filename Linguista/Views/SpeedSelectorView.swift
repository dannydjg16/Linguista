//
//  SpeedSelectorView.swift
//  Linguista
//
//  Created by Daniel Grant on 12/30/24.
//

import Foundation
import SwiftUI

//struct SpeedSelectorView: View {
//    @Binding var playbackSpeed: Float
//    
//    var body: some View {
//        VStack {
//            Text("Adjust Playback Speed")
//                .font(.headline)
//                .padding()
//            
//            Slider(value: $playbackSpeed, in: 0.5...1.0, step: 0.1) {
//                Text("Speed")
//            }
//            .padding()
//            
//            Text(String(format: "Speed: %.1fx", playbackSpeed))
//                .font(.subheadline)
//                .padding()
//            
//            Button(action: {
//                // Close the view
//                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
//            }) {
//                Text("Done")
//                    .bold()
//                    .padding()
//                    .background(Color.brown)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//    }
//}
struct SpeedSelectorView: View {
    @Binding var playbackSpeed: Float
    @Environment(\.presentationMode) var presentationMode

    let speedOptions: [Float] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

    var body: some View {
        VStack {
            Text("Adjust Playback Speed")
                .font(.headline)
                .padding()

            // Picker for speed options
            Picker("Speed", selection: $playbackSpeed) {
                ForEach(speedOptions, id: \.self) { speed in
                    Text("\(Int(speed * 100))%") // Converts Float to Int and appends %
                        .tag(speed)
                }
            }
            .pickerStyle(WheelPickerStyle()) // You can also use .MenuPickerStyle() for a dropdown
            .padding()

            Spacer() // Pushes the Done button to the bottom

            // Done Button
            HStack {
                Spacer()
                Button(action: {
                    // Dismiss the sheet
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .bold()
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding() // Add padding to keep it away from the edges
            }
        }
        .padding()
    }
}
