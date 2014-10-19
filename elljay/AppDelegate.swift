//
//  AppDelegate.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    @IBOutlet var window: UIWindow?
    
    func isRunningTests() -> Bool {
        return NSClassFromString("XCTestCase") != nil
    }

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        if(!isRunningTests()) {
            setup(launchOptions:launchOptions)
        }
        
        return true
    }
    
    func setup(#launchOptions : [NSObject : AnyObject]?) {
        let environment = RuntimeEnvironment()
        let authSession = environment.authSession
        
        let authController = AuthController(environment: environment)
        
        let rootController = UIViewController(nibName: nil, bundle: nil)
        rootController.beginAppearanceTransition(true, animated: false)
        window!.rootViewController = rootController
        let hasCredentials = authSession.hasCredentials
        if !hasCredentials {
            let loginController = LoginViewController(authController: authController)
            window?.rootViewController?.presentViewController(loginController, animated: false, completion: nil)
        }

    }

}

