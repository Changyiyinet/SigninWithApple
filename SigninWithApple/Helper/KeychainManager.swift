//
//  KeychainManager.swift
//  SigninWithApple
//
//  Created by Adhitya Surya Pratama on 03/10/19.
//  Copyright © 2019 Adhitya Surya Pratama. All rights reserved.
//

import Foundation

struct KeychainManager {
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }
    
    enum Key: String {
        case userID
        case firstName
        case lastName
        case email
    }
    
    let service: String
    let accessGroup: String?
    
    private(set) var account: String
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    func readItem() throws -> String {
        var keychainQuery = KeychainManager.keychainQuery(withService: service,
                                                       account: account,
                                                       accessGroup: accessGroup)
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecReturnAttributes as String] = kCFBooleanTrue
        keychainQuery[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }
        
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    func saveItem(_ password: String) throws {
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            try _ = readItem()
            
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = KeychainManager.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            var newItem = KeychainManager.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }
    
    func deleteItem() throws {
        let query = KeychainManager.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
    static func removeAllUserCredential() {
        KeychainManager.currentUserIdentifier = nil
        KeychainManager.currentUserFirstName = nil
        KeychainManager.currentUserLastName = nil
        KeychainManager.currentUserEmail = nil
    }
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}

extension KeychainManager {
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.skeletonwalk.SigninWithApple"
    }
    
    static var currentUserIdentifier: String? {
        get {
            return try? KeychainManager(service: bundleIdentifier, account: Key.userID.rawValue).readItem()
        }
        set {
            guard let value = newValue else {
                try? KeychainManager(service: bundleIdentifier, account: Key.userID.rawValue).deleteItem()
                return
            }
            do {
                try KeychainManager(service: bundleIdentifier, account: Key.userID.rawValue).saveItem(value)
            } catch {
                print("Unable to save ID to keychain.")
            }
        }
    }
    
    static var currentUserFirstName: String? {
        get {
            return try? KeychainManager(service: bundleIdentifier, account: Key.firstName.rawValue).readItem()
        }
        set {
            guard let value = newValue else {
                try? KeychainManager(service: bundleIdentifier, account: Key.firstName.rawValue).deleteItem()
                return
            }
            do {
                try KeychainManager(service: bundleIdentifier, account: Key.firstName.rawValue).saveItem(value)
            } catch {
                print("Unable to save FirstName to keychain.")
            }
        }
    }
    
    static var currentUserLastName: String? {
        get {
            return try? KeychainManager(service: bundleIdentifier, account: Key.lastName.rawValue).readItem()
        }
        set {
            guard let value = newValue else {
                try? KeychainManager(service: bundleIdentifier, account: Key.lastName.rawValue).deleteItem()
                return
            }
            do {
                try KeychainManager(service: bundleIdentifier, account: Key.lastName.rawValue).saveItem(value)
            } catch {
                print("Unable to save LastName to keychain.")
            }
        }
    }
        
    static var currentUserEmail: String? {
        get {
            return try? KeychainManager(service: bundleIdentifier, account: Key.email.rawValue).readItem()
        }
        set {
            guard let value = newValue else {
                try? KeychainManager(service: bundleIdentifier, account: Key.email.rawValue).deleteItem()
                return
            }
            do {
                try KeychainManager(service: bundleIdentifier, account: Key.email.rawValue).saveItem(value)
            } catch {
                print("Unable to save Email to keychain.")
            }
        }
    }
}
