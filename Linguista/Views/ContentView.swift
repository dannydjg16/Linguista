import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        TabView{
            LoginView()
                .tabItem {
                    Label("Login", systemImage: "person.fill")
                }
            NavigationView{
                MessagingView()
            }
                .tabItem {
                    Label("Messaging", systemImage: "")
                }
            QuickTranslateView()
                .tabItem {
                    Label("Translate", systemImage: "")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
