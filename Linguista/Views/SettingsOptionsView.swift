//
//  SettingsOptionsView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/22/25.
//

import Foundation
import SwiftUI

struct SettingsOptionsView: View {
    
    @Binding var languageToTranslate: Int
    @Binding var isShowingModal: Bool
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack() {
            Spacer()
            VStack {
                Button(action: {
                    isShowingModal = false
                    //dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.brown)
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 50, minHeight: 40, idealHeight: 50, maxHeight: 50)
                .background(Color.white )
                .clipShape(Circle())
            }
        }
        
        Text("Settings")
            .font(.title)
            .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
        Divider()
            .frame(height: 1)
            .background(Color.black.opacity(0.3))
            .padding(.leading)
            .padding(.trailing)
        
        NavigationView {
            LanguagePickerView(languageToTranslate: $languageToTranslate)
        }
        .tint(Color.brown)
        .padding(.top)
        
        HStack() {
            Spacer()
            VStack{
                Button(action: {
                    dismiss()
                    isShowingModal = false
                }) {
                    Text("Save")
                        .foregroundColor(Color.brown)
                    
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 50, minHeight: 40, idealHeight: 50, maxHeight: 50)
                .background(Color.white)
                .clipShape(Circle())
            }
            
            Spacer()
        }
    }
}
