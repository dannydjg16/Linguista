//
//  MessageListView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageListView: View {
    @ObservedObject var messagingViewModel: ConversationViewModel
    @State private var backgroundColor: Color = .blue

    var body: some View {
       //MyView()
        ZStack{
            backgroundColor
                .edgesIgnoringSafeArea(.all) // Make it cover the entire screen
            if let firstMessage = messagingViewModel.messages.first {
                Text("Topic: \(firstMessage.message.content)")
            }
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messagingViewModel.messages, id: \.id) { message in
                            MessageBubbleView(message: message, messagingViewModel: messagingViewModel)
                        }
                    }
                }
                .onChange(of: messagingViewModel.messages.count) {
                    // Here, I want to maybe change the color or picture on the screen. So when you should be talking and when the thing is tlaking.
                    // Might be a better way to do it but for now I have this array being checked anyways
                    
                    
                    
                    
                    
                    
                    if let lastIndex = messagingViewModel.messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                            backgroundColor = (backgroundColor == .blue) ? .green : .blue
                        }
                    }
                }
            }
        }

    }
    
    
    private func switchBackgroundColor() -> Color {
        return Color.blue
    }
}

struct MyView: View {
    @State private var backgroundColor: Color = .blue // Initial background color

    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all) // Make it cover the entire screen

            VStack {
                Text("Tap the button to change background color")
                    .foregroundColor(.white)
                    .padding()

                Button(action: {
                    // Toggle between blue and green
                    backgroundColor = (backgroundColor == .blue) ? .green : .blue
                }) {
                    Text("Change Background")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
        }
    }
}

