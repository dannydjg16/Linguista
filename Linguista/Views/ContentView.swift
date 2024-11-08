import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 1
    
    var body: some View {
        
        TabView(selection: $selectedTab){
            
            NavigationView{
                MessagingView()
            }
            .tabItem {
                Label("Messaging", systemImage: "questionmark.bubble.fill")
            }
            .tag(0)
            
            NavigationView{
                ConversationView()
            }
            .tabItem {
                Label("Chat", systemImage: "message.fill")
            }
            .tag(1)
            
            QuickTranslateView()
                .tabItem {
                    Label("Translate", systemImage: "arrow.left.arrow.right")
                }
                .tag(2)
            
            LoginView()
                .tabItem {
                    Label("Login", systemImage: "person.fill")
                }
                .tag(3)
            
//            NavigationView{
//                UserContextMessagingView()
//            }
//                .tabItem {
//                    Label("test", systemImage: "testtube.2")
//                }
//                .tag(4)
            NavigationView{
                //SpeechRecognizerView()
            }
                .tabItem {
                    Label("a", systemImage: "testtube.2")
                }
                .tag(4)
        }.accentColor(.brown)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
