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

class MockAuthController : AuthControlling {
    var credentials : AuthCredentials?
    func attemptLogin(#username : String, password : String, completion : (result : Result<AuthCredentials>) -> Void) {}
    
    func signOut() {}
}

class SuccessAuthController : MockAuthController {
    override func attemptLogin(#username: String, password: String, completion: (result: Result<AuthCredentials>) -> Void) {
        completion(result: Success(CredentialFactory.freshCredentials()))
    }
}

class FailureAuthController : MockAuthController {
    let message = "Failure"
    override func attemptLogin(#username: String, password: String, completion: (result: Result<AuthCredentials>) -> Void) {
        completion(result: Failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey : message])))
    }
}

class LoginViewControllerTests: XCTestCase {
    
    func testUsernameTab() {
        let controller = LoginViewController(environment:
            LoginViewControllerEnvironment(
                delegate : nil,
                authController : MockAuthController()))
        let _ = controller.view
        UIApplication.sharedApplication().delegate?.window??.rootViewController = controller
        controller.t_enterUsername("user")
        XCTAssertTrue(controller.t_isPasswordFirstResponder())
    }

    
    func testPasswordSuccess() {
        class LoginDelegate : LoginViewControllerDelegate {
            var activated = false
            func loginControllerSucceeded(controller: LoginViewController, credentials: AuthCredentials) {
                activated = true
            }
        }
        
        let delegate = LoginDelegate()
        let controller = LoginViewController(environment:
            LoginViewControllerEnvironment(
                delegate : delegate,
                authController : SuccessAuthController()))
        let _ = controller.view
        UIApplication.sharedApplication().delegate?.window??.rootViewController = controller
        controller.t_enterUsername("user")
        controller.t_enterPassword("password")
        XCTAssertTrue(delegate.activated)
    }
    
    func testPasswordFailed() {
        class AlertPresenter : AlertPresenting {
            var alert : UIAlertController? = nil
            private func presentAlertController(controller: UIAlertController, fromController: UIViewController) {
                alert = controller
            }
        }
        
        let presenter = AlertPresenter()
        let authController = FailureAuthController()
        
        let controller = LoginViewController(environment:
            LoginViewControllerEnvironment(
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
    }

}
