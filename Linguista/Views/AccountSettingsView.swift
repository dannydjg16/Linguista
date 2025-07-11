//
//  AccountSettingsView.swift
//  Linguista
//
//  Created by Daniel Grant on 7/2/25.
//

import Foundation
import SwiftUI

struct AccountSettingsView: View {
    
    @State var isShowingModal = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        
        HStack() {
            
            if (accountManager.isSignedIn()) {
                Button(action: {
                    accountManager.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            
            Spacer()
            
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
                .padding(.trailing)
            }
            .sheet(isPresented: $isShowingModal) {
                SettingsOptionsView(isShowingModal: $isShowingModal)
            }
        }
    }
}
