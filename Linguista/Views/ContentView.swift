import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0
    @State private var innerSelection = 0
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            ConversationViewsSwapperView()
            .tabItem {
                Label("Chat", systemImage: "phone.badge.waveform")
            }
            .tag(0)
            
            QuickTranslateView()
                .tabItem {
                    Label("Translate", systemImage: "arrow.left.arrow.right")
                }
                .tag(1)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(2)
            
        }.accentColor(.brown)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
