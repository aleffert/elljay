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

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        let environment = RuntimeEnvironment()
        
        let authController = AuthController(environment: environment)
        
        let rootController = UIViewController(nibName: nil, bundle: nil)
        rootController.beginAppearanceTransition(true, animated: false)
        window!.rootViewController = rootController
        if(!environment.authSession.hasCredentials) {
            let loginController = LoginViewController(authController: authController)
            window?.rootViewController.presentViewController(loginController, animated: false, completion: nil)
        }
        return true
    }

}

