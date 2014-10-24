//
//  Session.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import Security

class AuthSessionInfo : NSObject, NSCoding {
    let username : String
    let password : String
    
    init(username : String, password : String) {
        self.username = username
        self.password = password
    }
    
    required init(coder : NSCoder) {
        self.username = coder.decodeObjectForKey("username") as String
        self.password = coder.decodeObjectForKey("password") as String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.username, forKey:"username")
        coder.encodeObject(self.password, forKey:"password")
    }
    
    func challengeResponse(challenge : String) -> String {
        return ELJCrypto.md5OfString(challenge + ELJCrypto.md5OfString(self.password))
    }
}

class AuthSession {
    private let keychain : KeychainService
    private let urlSession : NSURLSession
    
    private(set) var storage : AuthSessionInfo?
    
    init(keychain : KeychainService, urlSession : NSURLSession) {
        self.keychain = keychain
        self.urlSession = urlSession
    }
    
    func loadFromKeychainIfPossible() {
        switch(keychain.load()) {
        case let .Success(storageData):
            storage = NSKeyedUnarchiver.unarchiveObjectWithData(storageData) as? AuthSessionInfo
            if let s = storage {
                if let urlStorage = urlSession.configuration.URLCredentialStorage {
                    let credential = NSURLCredential(user : s.username, password : s.password, persistence: .ForSession)
                    let space = NSURLProtectionSpace(host: "livejournal.com", port: 80, `protocol`: "https", realm: nil, authenticationMethod: "digest")
                    urlStorage.setCredential(credential, forProtectionSpace:space)
                }
            }
        case let .Failure(err):
            assert(Int(err) == Int(errSecItemNotFound), "Unexpected keychain error: \(Int32(err))")
            break
        }
    }

    func saveToKeychain() {
        let data = storage.bind { NSKeyedArchiver.archivedDataWithRootObject($0) }
        let err = data.bind { self.keychain.save($0) }
        assert(err == nil, "Unexpected keychain error: \(err)")
    }
    
    func store(storage : AuthSessionInfo) {
        self.storage = storage
    }

    func clear() {
        if let urlStorage = urlSession.configuration.URLCredentialStorage {
        }
        
        keychain.clear()
        self.storage = nil
    }
    
    var hasCredentials : Bool {
        return storage != nil
    }
}


protocol AuthSessionOwner {
    var authSession : AuthSession { get }
}
