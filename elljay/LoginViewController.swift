//
//  LoginViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

@objc protocol LoginViewControllerDelegate {
    func loginControllerSucceeded(controller : LoginViewController, credentials : AuthCredentials)
}

public class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let delegate : LoginViewControllerDelegate!
    
    @IBOutlet var contentContainer : UIView!
    
    @IBOutlet var usernameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    
    private(set) var authController : AuthController!
    
    init(authController : AuthController, delegate : LoginViewControllerDelegate)  {
        self.authController = authController
        self.delegate = delegate
        super.init(nibName: "LoginViewController", bundle : nil);
    }
    
    public required init(coder aDecoder: NSCoder) {
        assert(false, "Not designed to be loaded via archive")
        
        authController = aDecoder.decodeObjectForKey("authController") as AuthController
        delegate = aDecoder.decodeObjectForKey("delegate") as LoginViewControllerDelegate
        super.init(coder: aDecoder)
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

    func textFieldShouldReturn(textField: UITextField!) -> Bool  {
        if textField == usernameField {
            passwordField?.becomeFirstResponder()
        }
        else if textField == passwordField {
            textField.resignFirstResponder()
            authController.attemptLogin(username : usernameField.text, password: passwordField.text) { result in
                result.cata(
                    {credentials in
                        self.delegate.loginControllerSucceeded(self, credentials : credentials)
                        println("logged in")
                    },
                    {error in
                        println("error " + error.localizedDescription)
                    }
                )
            }
        }
        return false;
    }
}
