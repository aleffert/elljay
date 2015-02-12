//
//  LoginViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

public protocol LoginViewControllerDelegate : class {
    func loginControllerSucceeded(controller : LoginViewController, credentials : AuthCredentials)
}

public class LoginViewControllerEnvironment {
    private weak var delegate : LoginViewControllerDelegate?
    private let authController : AuthControlling
    private let alertPresenter : AlertPresenting
    
    public init(delegate : LoginViewControllerDelegate?, authController : AuthControlling, alertPresenter : AlertPresenting = AlertPresenter()) {
        self.authController = authController
        self.alertPresenter = alertPresenter
        self.delegate = delegate
    }
}

public class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private var contentContainer : UIView!
    
    @IBOutlet private var usernameField : UITextField!
    @IBOutlet private var passwordField : UITextField!
    
    private let environment : LoginViewControllerEnvironment
    
    public init(environment : LoginViewControllerEnvironment)  {
        self.environment = environment
        super.init(nibName: "LoginViewController", bundle : nil);
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("Not designed to be loaded via archive")
    }
    
    public override func viewDidLoad()  {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addAnimatedKeyboardObserver(self, view: self.view, action: {[weak self] (view, keyboardHeight) in
            let desiredBottom = self!.contentContainer!.center.y + self!.contentContainer!.bounds.size.height / 2
            let availableBottom = self!.view.bounds.size.height - keyboardHeight
            let actualBottom = min(availableBottom, desiredBottom)
            let delta = actualBottom - desiredBottom
            self!.contentContainer!.transform = CGAffineTransformMakeTranslation(0, delta);
        })
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func finishedField(textField : UITextField) {
        if textField == usernameField {
            passwordField?.becomeFirstResponder()
        }
        else if textField == passwordField {
            textField.resignFirstResponder()
            environment.authController.attemptLogin(username : usernameField.text, password: passwordField.text) { result in
                result.cata(
                    {credentials in
                        self.environment.delegate?.loginControllerSucceeded(self, credentials : credentials)
                        println("logged in")
                    },
                    {error in
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) {_ in })
                        self.environment.alertPresenter.presentAlertController(alert, fromController: self)
                    }
                )
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool  {
        finishedField(textField)
        return false;
    }

}

// only for use in tests
extension LoginViewController {
    
    public func t_enterUsername(username : String) {
        usernameField.text = username
        finishedField(usernameField)
    }
    
    public func t_enterPassword(password : String) {
        passwordField.text = password
        finishedField(passwordField)
    }
    
    public func t_isPasswordFirstResponder() -> Bool {
        return passwordField.isFirstResponder()
    }
}
