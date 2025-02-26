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
    @State private var isShowingModal = false
    @ObservedObject var conversationViewModel: ConversationViewModel

    var body: some View {
        
        HStack() {
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    isShowingModal = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.brown)
                }
                .frame(minWidth: 30, idealWidth: 50, maxWidth: 50, minHeight: 30, idealHeight: 50, maxHeight: 50)
                .background(Color.white )
                .clipShape(Circle())
            }
            .sheet(isPresented: $isShowingModal) {
                SettingsOptionsView(languageToTranslate: $languageToTranslate)
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    isShowingModal = true
                }) {
                    Image(systemName: "ellipsis.message")
                        .foregroundColor(.brown)
                }
                .frame(minWidth: 30, idealWidth: 50, maxWidth: 50, minHeight: 30, idealHeight: 50, maxHeight: 50)
                .background(Color.white )
                .clipShape(Circle())
            }
            .sheet(isPresented: $isShowingModal) {
                SettingsOptionsView(languageToTranslate: $languageToTranslate)
            }
        }

    }
}
