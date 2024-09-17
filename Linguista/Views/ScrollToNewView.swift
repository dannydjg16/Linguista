//
//  ScrollToNewView.swift
//  Linguista
//
//  Created by Daniel Grant on 9/16/24.
//

import SwiftUI

struct ScrollToNewView: View {
    @State private var messages: [String] = ["Hello", "How are you?", "I'm fine, thank you!"]
    @State private var newMessage: String = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(messages.indices, id: \.self) { index in
                            Text(messages[index])
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .id(index) // Assign an ID for each message
                        }
                    }
                }
                .onChange(of: messages) { _ in
                    // Scroll to the last message when new messages are added
                    if let lastIndex = messages.indices.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Text field and send button
            HStack {
                TextField("New message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button(action: {
                    sendMessage()
                }) {
                    Text("Send")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        if !newMessage.isEmpty {
            messages.append(newMessage)
            newMessage = ""
        }
    }
}

struct ScrollToNewView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollToNewView()
    }
}
