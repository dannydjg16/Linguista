import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            ConversationViewsSwapperView()
                .tabItem {
                    Label("Chat", systemImage: "phone.badge.waveform")
                }
                .tag(0)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(1)
            AccountFormView()
                .tabItem {
                    Label("Add Account", systemImage: "person.crop.circle.fill")
                }
                .tag(2)
            AccountListView()
                .tabItem {
                    Label("Accounts", systemImage: "list.bullet")
                }
                .tag(3)
            
        }.accentColor(.brown)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
