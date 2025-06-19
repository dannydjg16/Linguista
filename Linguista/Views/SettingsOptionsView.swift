//
//  SettingsOptionsView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/22/25.
//

import Foundation
import SwiftUI

struct SettingsOptionsView: View {
    
    @Binding var isShowingModal: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack() {
            Spacer()
            VStack {
                Button(action: {
                    dismiss()
                    isShowingModal = false
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
            .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
        
        Divider()
            .frame(height: 1)
            .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
            .padding(.leading)
            .padding(.trailing)
        
        HStack {
            Text("Language to Learn:")
                .padding(.leading)
                .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
            Spacer()
        }
        
        LanguagePickerView()
            .padding(.top)
        
        Spacer()
        
        HStack {
            Spacer()
            Button(action: {
                dismiss()
                isShowingModal = false
            }) {
                Text("Done")
                    .bold()
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
