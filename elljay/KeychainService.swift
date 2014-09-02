//
//  KeychainService.swift
//  elljay
//
//  Created by Akiva Leffert on 8/29/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import Security

typealias KeychainSaveResult = OSStatus?

class KeychainService {
    
    let serviceName : String
    
    init(serviceName : String) {
        self.serviceName = serviceName;
    }

    func save(data: NSData) -> KeychainSaveResult {
        // Instantiate a new default keychain query
        var keychainQuery = NSMutableDictionary(dictionary : [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : serviceName,
            kSecValueData : data
        ]) as CFDictionaryRef
        
        // Delete any existing items
        var status = SecItemDelete(keychainQuery)
        if(Int(status) != errSecSuccess && Int(status) != errSecItemNotFound) {
            return status
        }
        
        // Add the new keychain item
        status = SecItemAdd(keychainQuery, nil)
        if(Int(status) != errSecSuccess) {
            return status
        }
        return nil
    }
    
    enum KeychainLoadResult {
        case Success(NSData)
        case Failure(OSStatus)
    }

    func load() -> KeychainLoadResult {
        
        var keychainQuery = NSMutableDictionary(dictionary : [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : serviceName,
            kSecReturnData : kCFBooleanTrue,
            kSecMatchLimit : kSecMatchLimitOne
            ]) as CFDictionaryRef
        
        var dataTypeRef : Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: NSString?
        
        if let op = opaque {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeRetainedValue()
            
            return KeychainLoadResult.Success(retrievedData)
        } else {
            return KeychainLoadResult.Failure(status)
        }
    }
    
}
