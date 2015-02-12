//
//  AuthControllerTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/8/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class AuthControllerTests: XCTestCase {
    
    func freshEnvironment() -> (
        keychain : KeychainServicing,
        credentials : AuthCredentials,
        controller : AuthController) {

        let ljservice = LJService()
        let keychain = EphemeralKeychainService()
        let credentials = CredentialFactory.freshCredentials()
        let authSession = AuthSession(keychain: keychain)
        
        let networkService = NetworkService(
            session: NSURLSession.sharedSession(),
            challengeGenerator: ljservice
        )
        
        let controller = AuthController(
            environment: AuthControllerEnvironment(
                authSession : authSession,
                ljservice : ljservice,
                networkService : networkService)
        )
        
        return (keychain : keychain, credentials : credentials, controller : controller)
    }
    
    func testLoadExistingCredentials() {
        let (keychain, credentials, controller) = freshEnvironment()
        keychain.save(NSKeyedArchiver.archivedDataWithRootObject(credentials))
        XCTAssertEqual(controller.credentials!, credentials)
    }
    
    func testLoadFreshCredentialsSuccess() {
        LJServiceTestHelpers.stubChallenge()
        LJServiceTestHelpers.stubLoginSuccess()
        let (keychain, credentials, controller) = freshEnvironment()
        XCTAssertNil(controller.credentials)
        
        let expectation = expectationWithDescription("login ended")
        controller.attemptLogin(username : credentials.username, password : credentials.password) {
            result in
            XCTAssertNotNil(controller.credentials)
            XCTAssertEqual(controller.credentials!, credentials)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
        OHHTTPStubs.removeLastStub()
        OHHTTPStubs.removeLastStub()
    }
    
    func testLoadFreshCredentialsFailure() {
        LJServiceTestHelpers.stubChallenge()
        LJServiceTestHelpers.stubLoginFailure()
        let (keychain, credentials, controller) = freshEnvironment()
        XCTAssertNil(controller.credentials)
        
        let expectation = expectationWithDescription("login ended")
        controller.attemptLogin(username : credentials.username, password : credentials.password) {
            result in
            XCTAssertNil(controller.credentials)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
        OHHTTPStubs.removeLastStub()
        OHHTTPStubs.removeLastStub()
    }
    
    func testSignOut() {
        let (keychain, credentials, controller) = freshEnvironment()
        keychain.save(NSKeyedArchiver.archivedDataWithRootObject(credentials))
        XCTAssertNotNil(controller.credentials)
        controller.signOut()
        XCTAssertNil(controller.credentials)
    }
}
