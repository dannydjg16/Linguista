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
    
    //    var body: some View {
    //        HStack {
    //            Spacer()
    //            VStack{
    //                Button(action: {
    //                    // Action when the button is tapped
    //                    SettingsOptionsView(languageToTranslate: $languageToTranslate)
    //
    //                }) {
    //                    Image(systemName: "gear")
    //                        .foregroundColor(.brown)
    //                }
    //                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
    //                .background(Color.white )
    //                .clipShape(Circle())
    //            }
    //        }
    //    }
    var body: some View {
        Button("Show Modal") {
            isShowingModal = true
        }
        .sheet(isPresented: $isShowingModal) {
            SettingsOptionsView(languageToTranslate: $languageToTranslate)
        }
    }
}
