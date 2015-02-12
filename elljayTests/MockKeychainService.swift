//
//  MockKeychainService.swift
//  elljay
//
//  Created by Akiva Leffert on 2/8/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

import elljay

public class MockKeychainService: KeychainServicing {
    var store : NSData?
    
    public init() {
        
    }
    
    public func save(data : NSData) -> OSStatus {
        store = data
        return errSecSuccess
    }
    
    public func load() -> KeychainLoadResult {
        if let s = store {
            return .Success(s)
        }
        else {
            return .Failure(errSecItemNotFound)
        }
    }
    
    public func clear() -> OSStatus {
        store = nil
        return errSecSuccess
    }
    

}
