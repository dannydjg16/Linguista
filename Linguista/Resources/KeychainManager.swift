//
//  KeychainManager.swift
//  Linguista
//
//  Created by Daniel Grant on 5/15/25.
//

import Security
import Foundation

class KeychainManager {
    
    static func save(key: String, data: String) -> Bool {
        if let data = data.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as CFDictionary
            
            SecItemDelete(query)
            return SecItemAdd(query, nil) == noErr
        }
        return false
    }
    
    static func load(key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr, let data = dataTypeRef as? Data, let result = String(data: data, encoding: .utf8) {
            return result
        }
        return nil
    }
    
    static func delete(key: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        return SecItemDelete(query) == noErr
    }
}
