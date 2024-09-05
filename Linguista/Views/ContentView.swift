import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        
        TabView(selection: $selectedTab){
            
            LoginView()
                .tabItem {
                    Label("Login", systemImage: "person.fill")
                }
                .tag(0)
            
            NavigationView{
                MessagingView()
            }
            .tabItem {
                Label("Messaging", systemImage: "message.fill")
            }
            .tag(1)
            
            QuickTranslateView()
                .tabItem {
                    Label("Translate", systemImage: "arrow.left.arrow.right")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
