//
//  LoginViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var contentContainer : UIView?
    
    @IBOutlet var usernameField : UITextField?
    @IBOutlet var passwordField : UITextField?
    
    let service : Service
    
    init(service : Service)  {
        self.service = service
        super.init(nibName: nil, bundle : nil);
    }
    
    required init(coder aDecoder: NSCoder) {
        service = aDecoder.decodeObjectForKey("service") as Service
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
            service.loginWithUsername(self.usernameField!.text, password: self.passwordField!.text)
        }
        return false;
    }
}
