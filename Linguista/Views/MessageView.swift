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
                fetchFromAPI()
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

func fetchFromAPI() {
    // Use 127.0.0.1 for the simulator or your local IP address for a physical device
    let urlString = "http://192.168.1.100:7244/api/yourendpoint" // replace with your actual IP and endpoint
    guard let url = URL(string: urlString) else { return }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        guard let data = data else { return }

        do {
            // Parse the data here
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("Response JSON: \(json)")
        } catch let jsonError {
            print("Error parsing JSON: \(jsonError)")
        }
    }

    task.resume()
}
