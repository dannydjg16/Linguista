//
//  Config.swift
//  Linguista
//
//  Created by Daniel Grant on 8/9/24.
//

import Foundation

class Config {
    static let shared = Config()
    
    private var config: [String: Any] = [:]
    
    private init() {
        #if DEBUG
        loadConfig(from: "Config")
        #else
        loadConfig(from: "ConfigRelease")
        #endif
    }
    
    private func loadConfig(from fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let config = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            self.config = config
        }
    }
    
    func value(forKey key: String) -> String? {
        return config[key] as? String
    }
}
