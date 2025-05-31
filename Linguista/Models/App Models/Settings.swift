//
//  Settings.swift
//  Linguista
//
//  Created by Daniel Grant on 2/24/25.
//

import SwiftUI

class Settings: ObservableObject {
    
    @UserDefault(key: "languageToLearn", defaultValue: 1)    
    var languageToLearn: Int {
        willSet { objectWillChange.send() } // Notify SwiftUI of changes
    }
    
    @UserDefault(key: "learningLevel", defaultValue: 1)
    var learningLevel: Int {
        willSet { objectWillChange.send() } // Notify SwiftUI of changes
    }
}
