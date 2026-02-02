//
//  Utilities.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation

struct Utilities {
    
    static func getLanguageName(by id: Int) -> String {
        return popularLanguageObjects.first { $0.id == id }!.name
    }
    
}
