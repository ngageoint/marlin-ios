//
//  Keychain.swift
//  Marlin
//
//  Created by Daniel Barela on 4/14/23.
//

import Foundation
import AuthenticationServices

class Keychain {
    
    func getCredentials(server: String, account: String) -> Credentials? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecAttrAccount as String: account,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            return nil
        }
        guard status == errSecSuccess else {
            return nil
        }
        
        guard let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8),
              let account = existingItem[kSecAttrAccount as String] as? String
        else {
            return nil
        }
        return Credentials(username: account, password: password)
    }
    
    func update(server: String, credentials: Credentials) -> Credentials? {
        let account = credentials.username
        let password = credentials.password.data(using: String.Encoding.utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecAttrAccount as String: account]
        
        let attributes: [String: Any] = [kSecAttrAccount as String: account,
                                         kSecValueData as String: password]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            return nil
        }
        guard status == errSecSuccess else {
            return nil
        }
        return credentials
    }
    
    @discardableResult
    func addOrUpdate(server: String, credentials: Credentials) -> Bool {
        let account = credentials.username
        let password = credentials.password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: server,
                                    kSecValueData as String: password]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecDuplicateItem:
            if update(server: server, credentials: credentials) != nil {
                return true
            } else {
                return false
            }
        case errSecSuccess:
            return true
        default:
            return false
        }
    }
}

struct Credentials {
    var username: String
    var password: String
}
