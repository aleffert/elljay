//
//  AuthSessionTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/8/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class AuthSessionTests: XCTestCase {
    private let keychain = MockKeychainService()
    private let credentials = CredentialFactory.freshCredentials()
    
    override func tearDown() {
        keychain.clear()
    }

    func testInitFromEmptyStore() {
        let session = AuthSession(keychain : keychain)
        XCTAssertNil(session.credentials)
    }
    
    func testInitFromFullStore() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(credentials)
        keychain.save(data)
        let session = AuthSession(keychain : keychain)
        session.loadFromKeychainIfPossible()
        XCTAssertNotNil(session.credentials)
        XCTAssertEqual(credentials, session.credentials!)
    }
    
    func testRestoreBetweenSessions() {
        let session = AuthSession(keychain : keychain)
        session.store(credentials)
        session.saveToKeychain()
        
        let nextSession = AuthSession(keychain: keychain)
        nextSession.loadFromKeychainIfPossible()
        XCTAssertNotNil(session.credentials)
        XCTAssertEqual(credentials, session.credentials!)
    }
}
