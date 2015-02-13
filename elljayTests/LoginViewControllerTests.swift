//
//  LoginViewControllerTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/11/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class StubAuthController : AuthControlling {
    var credentials : AuthCredentials?
    func attemptLogin(#username : String, password : String, completion : (result : Result<AuthCredentials>) -> Void) {}
    
    func signOut() {}
}

class MockSuccessAuthController : StubAuthController {
    override func attemptLogin(#username: String, password: String, completion: (result: Result<AuthCredentials>) -> Void) {
        completion(result: Success(CredentialFactory.freshCredentials()))
    }
}

class MockFailureAuthController : StubAuthController {
    let message = "Failure"
    override func attemptLogin(#username: String, password: String, completion: (result: Result<AuthCredentials>) -> Void) {
        completion(result: Failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey : message])))
    }
}

class LoginViewControllerTests: XCTestCase {
    
    func testUsernameTab() {
        let controller = LoginViewController(environment:
            LoginViewController.Environment(
                delegate : nil,
                authController : StubAuthController()))
        let _ = controller.view
        UIApplication.sharedApplication().delegate?.window??.rootViewController = controller
        controller.t_enterUsername("user")
        XCTAssertTrue(controller.t_isPasswordFirstResponder())
    }

    
    func testPasswordSuccess() {
        class MockLoginDelegate : LoginViewControllerDelegate {
            var activated = false
            func loginControllerSucceeded(controller: LoginViewController, credentials: AuthCredentials) {
                activated = true
            }
        }
        
        let delegate = MockLoginDelegate()
        let controller = LoginViewController(environment:
            LoginViewController.Environment(
                delegate : delegate,
                authController : MockSuccessAuthController()))
        let _ = controller.view
        UIApplication.sharedApplication().delegate?.window??.rootViewController = controller
        controller.t_enterUsername("user")
        controller.t_enterPassword("password")
        XCTAssertTrue(delegate.activated)
    }
    
    func testPasswordFailed() {
        class MockAlertPresenter : AlertPresenting {
            var alert : UIAlertController? = nil
            private func presentAlertController(controller: UIAlertController, fromController: UIViewController) {
                alert = controller
            }
        }
        
        let presenter = MockAlertPresenter()
        let authController = MockFailureAuthController()
        
        let controller = LoginViewController(environment:
            LoginViewController.Environment(
                delegate : nil,
                authController : authController,
                alertPresenter : presenter
            )
        )
        let _ = controller.view
        UIApplication.sharedApplication().delegate?.window??.rootViewController = controller
        controller.t_enterUsername("user")
        controller.t_enterPassword("password")
        XCTAssertNotNil(presenter.alert)
        XCTAssertEqual(presenter.alert!.message!, authController.message)
        XCTAssertEqual(presenter.alert!.actions.count, 1)
        let action = presenter.alert!.actions[0] as UIAlertAction
        XCTAssertEqual(action.title, "OK")
    }

}
