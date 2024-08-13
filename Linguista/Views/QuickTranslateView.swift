//
//  QuickTranslateView.swift
//  Linguista
//
//  Created by Daniel Grant on 8/9/24.
//

import Foundation
import SwiftUI

struct QuickTranslateView: View {
    @State private var stepValue = 0
    //@State private var selection = 1
    @State private var date = Date()
    @State private var text = "Enter your message"
    @State private var items = ["Feature 1", "Feature 2", "Feature 3"]
    @State private var selection: [String: Bool] = [:]

    func handleOption1() {
        print("Option 1 selected")
        // Add your action for Option 1 here
    }

    func handleOption2() {
        print("Option 2 selected")
        // Add your action for Option 2 here
    }
    
    var body: some View {
        VStack{
            Picker("Select a number", selection: $selection) {
                Text("One").tag(1)
                Text("Two").tag(2)
                Text("Three").tag(3)
            }
            .pickerStyle(MenuPickerStyle())
            
            List {
                Section(header: Text("Header")) {
                    Text("Item 1")
                    Text("Item 2")
                }
                Section(header: Text("Header2")) {
                    Text("Item 3")
                    Text("Item 4")
                }
            }
        }
//        TabView {
//            Text("Tab 1").tabItem { Text("First") }
//            Text("Tab 2").tabItem { Text("Second") }
//        }
        List {
            Section(header: Text("Header")) {
                Text("Item 1")
                Text("Item 2")
            }
            Section(header: Text("Header2")) {
                Text("Item 3")
                Text("Item 4")
            }
        }
    }
}

struct QuickTranslateView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTranslateView()
    }
}
