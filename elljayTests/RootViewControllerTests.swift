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
    
    class Environment {
        let rootEnvironment : RootViewController.Environment
        let keychain : KeychainServicing = EphemeralKeychainService()
        
        init() {
            rootEnvironment = RootViewController.Environment(
                dataStoreFactory: {
                    return EphemeralUserDataStore(userID: $0)
                },
                keychain: keychain,
                ljservice: LJService())
        }
    }
    
    
    func testNoCredentials() {
        let env = Environment()
        let controller = RootViewController(environment: env.rootEnvironment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingLoginView())
    }
    
    func testCredentials() {
        let env = Environment()
        env.keychain.save(NSKeyedArchiver.archivedDataWithRootObject(
            CredentialFactory.freshCredentials())
        )
        let controller = RootViewController(environment: env.rootEnvironment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingAuthenticatedView())
    }
    
    func testSignIn() {
        let env = Environment()
        let controller = RootViewController(environment: env.rootEnvironment)
        let _ = controller.view
        XCTAssertTrue(controller.t_showingLoginView())
        controller.t_login(CredentialFactory.freshCredentials())
        XCTAssertTrue(controller.t_showingAuthenticatedView())
    }
    
    func testSignOut() {
        let env = Environment()
        let controller = RootViewController(environment: env.rootEnvironment)
        env.keychain.save(NSKeyedArchiver.archivedDataWithRootObject(
            CredentialFactory.freshCredentials())
        )
        let _ = controller.view
        XCTAssertTrue(controller.t_showingAuthenticatedView())
        controller.t_signOut()
        XCTAssertTrue(controller.t_showingLoginView())
        XCTAssertNil(env.rootEnvironment.authSession.credentials)
    }
    
    func testSignInOut() {
        let env = Environment()
        let controller = RootViewController(environment: env.rootEnvironment)
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
        XCTAssertNil(env.rootEnvironment.authSession.credentials)
    }
   
}
