//
//  MessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation
import SwiftUI

struct MessagingView: View {
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var currentMessage = ""
    

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach($messagingViewModel.messages, id: \.id) { $message in
                        HStack {
                            if message.isSentByUser {
                                Spacer()
                                Text(message.message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text(message.message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    messagingViewModel.sendMessage(text: currentMessage)
                    currentMessage = ""
                }) {
                    Text("Send")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
