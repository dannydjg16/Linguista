import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        SettingsView(selectedTab: $selectedTab)
        
        TabView(selection: $selectedTab) {
            
            TextMessagingView()
                .tag(0)
                .tabItem {
                    Label("Text", systemImage: "bubble.and.pencil")
                }
            
            ChatView()
                .tag(1)
                .tabItem {
                    Label("Talk", systemImage: "microphone")
                }
            
            AccountView()
                .tag(2)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
            
        }.accentColor(.brown)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
