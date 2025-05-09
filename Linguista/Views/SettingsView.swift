//
//  SettingsView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/22/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @Binding var languageToTranslate: Int
    @State var isShowingModal = false
    @State private var isShowingChatSettingsModal = false
    @ObservedObject var conversationViewModel: ConversationViewModel
    @Binding var chatTabViewSelectedValue: Int
    @Environment(\.colorScheme) var colorScheme

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
                SettingsOptionsView(languageToTranslate: $languageToTranslate, isShowingModal: $isShowingModal)
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
                ChatOptionsView(languageToTranslate: $languageToTranslate, chatTabViewSelectedValue: $chatTabViewSelectedValue, conversationViewModel: conversationViewModel)
            }
        }
    }
}
