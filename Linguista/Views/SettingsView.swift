//
//  SettingsView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/22/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @State var isShowingModal = false
    @State private var isShowingChatSettingsModal = false
    @Binding var chatTabViewSelectedValue: Int
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var conversationViewModel: ConversationViewModel

    var body: some View {
        
        HStack() {
            VStack{
                Button(action: {
                    isShowingModal = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(colorScheme == .light ? Color.brown : Color.white)
                }
                .frame(minWidth: 30, idealWidth: 50, maxWidth: 50, minHeight: 30, idealHeight: 50, maxHeight: 50)
                .background(colorScheme == .light ? Color.white : Color.black)
                .border(Color.brown, width: 2)
                .clipShape(Circle())
                .padding(.leading)
            }
            .sheet(isPresented: $isShowingModal) {
                SettingsOptionsView(isShowingModal: $isShowingModal)
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    isShowingChatSettingsModal = true
                }) {
                    Image(systemName: "ellipsis.message")
                    .foregroundColor(colorScheme == .light ? Color.brown : Color.white)
                }
                .frame(minWidth: 30, idealWidth: 50, maxWidth: 50, minHeight: 30, idealHeight: 50, maxHeight: 50)
                .background(colorScheme == .light ? Color.white : Color.black)
                .border(Color.brown, width: 2)
                .clipShape(Circle())
                .padding(.trailing)
            }
            .sheet(isPresented: $isShowingChatSettingsModal) {
                ChatOptionsView(chatTabViewSelectedValue: $chatTabViewSelectedValue)
            }
        }
    }
}
