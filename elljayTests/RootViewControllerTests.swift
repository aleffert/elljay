//
//  RootViewControllerTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/8/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay


class RootViewControllerTests: XCTestCase {
    
    func freshTestEnvironment() -> (RootEnvironment, KeychainServicing) {
        let keychain = EphemeralKeychainService()
        return (RootEnvironment(ljservice : LJService(), keychain : keychain), keychain)
    }
    
    func testNoCredentials() {
        let (environment, keychain) = freshTestEnvironment()
        let controller = RootViewController(environment: environment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingLoginView())
    }
    
    func testCredentials() {
        let (environment, keychain) = freshTestEnvironment()
        keychain.save(NSKeyedArchiver.archivedDataWithRootObject(
            CredentialFactory.freshCredentials())
        )
        let controller = RootViewController(environment: environment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingAuthenticatedView())
    }
    
    func testSignIn() {
        let (environment, keychain) = freshTestEnvironment()
        let controller = RootViewController(environment: environment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingLoginView())
        controller.t_login(CredentialFactory.freshCredentials())
        XCTAssertTrue(controller.t_showingAuthenticatedView())
    }
    
    func testSignOut() {
        let (environment, keychain) = freshTestEnvironment()
        let controller = RootViewController(environment: environment)
        keychain.save(NSKeyedArchiver.archivedDataWithRootObject(
            CredentialFactory.freshCredentials())
        )
        let _ = controller.view
        XCTAssertTrue(controller.t_showingAuthenticatedView())
        controller.t_signOut()
        XCTAssertTrue(controller.t_showingLoginView())
        XCTAssertNil(environment.authSession.credentials)
    }
    
    func testSignInOut() {
        let (environment, keychain) = freshTestEnvironment()
        let controller = RootViewController(environment: environment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingLoginView())
        controller.t_login(CredentialFactory.freshCredentials())
        XCTAssertTrue(controller.t_showingAuthenticatedView())
        
        let expectation = expectationWithDescription("Transitioned")
        
        // wait an iteration for view controller transitions to propagate
        dispatch_async(dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
        
        controller.t_signOut()
        XCTAssertTrue(controller.t_showingLoginView())
        XCTAssertNil(environment.authSession.credentials)
    }
   
}
