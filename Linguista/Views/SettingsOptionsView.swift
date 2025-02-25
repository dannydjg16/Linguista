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
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack() {
            Spacer()
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.brown)
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 50, minHeight: 40, idealHeight: 50, maxHeight: 50)
                .background(Color.white )
                .clipShape(Circle())
            }
        }
        Spacer()
        
        NavigationView {
            LanguagePickerView(languageToTranslate: $languageToTranslate)
        }
        .tint(Color.brown)
        
        
        Spacer()
        
        HStack() {
            Spacer()
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    dismiss()
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
