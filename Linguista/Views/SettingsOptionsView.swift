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
        VStack {
            Text("This is the modal view")
            Button("Dismiss") {
                dismiss()
            }
        }
    }
}
