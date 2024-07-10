//import SwiftUI
//
//struct ContentView: View {
//    @State private var userInput: String = ""
//    @State private var responseMessage: String = ""
//    
//    var body: some View {
//        VStack {
//            TextField("Enter your input", text: $userInput)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            Button(action: {
//                sendRequest { response in
//                    DispatchQueue.main.async {
//                        self.responseMessage = response
//                    }
//                }
//            }) {
//                Text("Send Request")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .padding()
//            
//            Text("Response: \(responseMessage)")
//                .padding()
//        }
//        .padding()
//    }
//    
//    func sendRequest(completion: @escaping (String) -> Void) {
//        guard let url = URL(string: "https://localhost:7244/OpenAi/completions") else {
//            print("Invalid URL")
//            completion("Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"  // Use GET if no body is required
//        
//        let session = URLSession(configuration: .default, delegate: URLSessionDelegateImpl(), delegateQueue: nil)
//        
//        let task = session.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                completion("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received")
//                completion("No data received")
//                return
//            }
//            
//            do {
//                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let content = jsonResponse["content"] as? String {
//                    completion(content)
//                } else {
//                    print("Invalid response format")
//                    completion("Invalid response format")
//                }
//            } catch {
//                print("Failed to parse JSON: \(error.localizedDescription)")
//                completion("Failed to parse JSON: \(error.localizedDescription)")
//            }
//        }
//        
//        task.resume()
//    }
//}
//
//class URLSessionDelegateImpl: NSObject, URLSessionDelegate {
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        // Trust the certificate even if it is self-signed
//        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//    }
//}
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                NavigationLink(destination: LanguageSelectionView()) {
                    Text("Quick Learn")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
