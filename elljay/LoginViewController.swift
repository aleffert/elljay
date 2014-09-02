//
//  LoginViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var contentContainer : UIView!
    
    @IBOutlet var usernameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    
    private(set) var authController : AuthController!
    
    init(authController : AuthController)  {
        self.authController = authController
        super.init(nibName: "LoginViewController", bundle : nil);
    }
    
    required init(coder aDecoder: NSCoder) {
        authController = aDecoder.decodeObjectForKey("authController") as AuthController
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addAnimatedKeyboardObserver(self, view: self.view, action: {[weak self] (view, keyboardHeight) in
            let desiredBottom = self!.contentContainer!.center.y + self!.contentContainer!.bounds.size.height / 2
            let availableBottom = self!.view.bounds.size.height - keyboardHeight
            let actualBottom = min(availableBottom, desiredBottom)
            let delta = actualBottom - desiredBottom
            self!.contentContainer!.transform = CGAffineTransformMakeTranslation(0, delta);
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool  {
        if textField == usernameField {
            passwordField?.becomeFirstResponder()
        }
        else if textField == passwordField {
            textField.resignFirstResponder()
            authController.attemptLogin(usernameField.text, password: passwordField.text, completion: { (success, error) in
                if error != nil {
                    println("error " + error!.localizedDescription)
                }
                else {
                    println("logged in")
                }
            })
        }
        return false;
    }
}
