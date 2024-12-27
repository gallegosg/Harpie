//
//  Auth.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/15/24.
//

import Foundation

struct Auth {
    func checkIfLoggedIn() -> Bool {
        return retrieveRefreshToken() != nil
    }
    
    func saveRefreshToken(_ token: String) -> Bool {
        let data = token.data(using: .utf8)!
        
        // Define keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "refresh_token",
            kSecAttrService as String: "com.gerardogallegos.harpie.service",
            kSecValueData as String: data
        ]
        
        // Delete any existing token
        SecItemDelete(query as CFDictionary)
        
        // Add new token
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieveRefreshToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "refresh_token",
            kSecAttrService as String: "com.gerardogallegos.harpie.service",
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func deleteRefreshToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "refresh_token",
            kSecAttrService as String: "com.gerardogallegos.harpie.service"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
}
