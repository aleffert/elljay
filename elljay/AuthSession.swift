//
//  Session.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import Security

public class AuthCredentials : NSObject, NSCoding, Equatable {
    public let username : String
    public let password : String
    
    public init(username : String, password : String) {
        self.username = username
        self.password = password
    }
    
    public required init(coder : NSCoder) {
        self.username = coder.decodeObjectForKey("username") as String
        self.password = coder.decodeObjectForKey("password") as String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.username, forKey:"username")
        coder.encodeObject(self.password, forKey:"password")
    }
    
    func challengeResponse(challenge : String) -> String {
        return ELJCrypto.md5OfString(challenge + ELJCrypto.md5OfString(self.password))
    }
    
    func hash() -> Int {
        return username.hash ^ password.hash
    }
}


public func ==(lhs : AuthCredentials, rhs : AuthCredentials) -> Bool {
    return lhs.username == rhs.username && lhs.password == rhs.password
}

public class AuthSession {
    private let keychain : KeychainService
    
    public private(set) var credentials : AuthCredentials?
    
    public init(keychain : KeychainService) {
        self.keychain = keychain
    }
    
    public func loadFromKeychainIfPossible() {
        switch(keychain.load()) {
        case let .Success(storageData):
            credentials = NSKeyedUnarchiver.unarchiveObjectWithData(storageData) as? AuthCredentials
        case let .Failure(err):
            assert(Int(err) == Int(errSecItemNotFound), "Unexpected keychain error: \(Int32(err))")
            break
        }
    }

    public func saveToKeychain() {
        let data = credentials.bind { NSKeyedArchiver.archivedDataWithRootObject($0) }
        let err = data.bind { self.keychain.save($0) }
        assert(err == errSecSuccess, "Unexpected keychain error: \(err)")
    }
    
    public func store(credentials : AuthCredentials) {
        self.credentials = credentials
    }

    public func clear() {
        keychain.clear()
        credentials = nil
    }
}

