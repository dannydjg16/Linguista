//
//  TextMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TextMessagingView: View {
    
    @Binding var selectedTab: Int

    var body: some View {
        VStack{
            SettingsView(selectedTab: $selectedTab)
            
            MessageListView()
            
            MessageInputView()
        }
    }
}

struct TextMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        TextMessagingView(selectedTab: .constant(1))
    }
}
