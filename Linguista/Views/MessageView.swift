//
//  MessageView.swift
//  Linguista
//
//  Created by Daniel Grant on 7/10/24.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @ObservedObject var viewModel = MessageViewModel()
    
    var body: some View {
        VStack {
            Text("Completion Request Example")
                .font(.title)
                .padding()

            if let response = viewModel.completionResponse {
                Text("Response ID: \(response.id ?? "N/A")")
                Text("Model: \(response.model ?? "N/A")")
                if let choices = response.choices {
                    ForEach(choices, id: \.self) { choice in
                        Text("Choice: \(choice.message.content)")
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }

            Button(action: {
                viewModel.sendRequest()
            }) {
                Text("Send Request")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
