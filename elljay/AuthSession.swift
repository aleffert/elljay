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
    public let userID : String
    public let password : String
    
    public init(username : String, password : String) {
        self.userID = username
        self.password = password
    }
    
    public required init(coder : NSCoder) {
        self.userID = coder.decodeObjectForKey("username") as String
        self.password = coder.decodeObjectForKey("password") as String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.userID, forKey:"username")
        coder.encodeObject(self.password, forKey:"password")
    }
    
    func challengeResponse(challenge : String) -> String {
        return ELJCrypto.md5OfString(challenge + ELJCrypto.md5OfString(self.password))
    }
    
    func hash() -> Int {
        return userID.hash ^ password.hash
    }
}


public func ==(lhs : AuthCredentials, rhs : AuthCredentials) -> Bool {
    return lhs.userID == rhs.userID && lhs.password == rhs.password
}

public class AuthSession {
    private let keychain : KeychainServicing
    
    public private(set) var credentials : AuthCredentials?
    
    public init(keychain : KeychainServicing) {
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

