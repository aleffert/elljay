//
//  RootViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/20/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

protocol AppRouter {
    func signOut()
}

class RootViewController: UIViewController, LoginViewControllerDelegate, AppRouter {
    
    let contentController = UITabBarController()
    let settingsController = SettingsViewController()
    let environment : RuntimeEnvironment
    let authController : AuthController
    
    var currentController : UIViewController?
    
    init(environment : RuntimeEnvironment) {
        self.environment = environment
        self.authController = AuthController(environment: environment)
        super.init(nibName: nil, bundle: nil)
        settingsController.router = self
        
        addChildViewController(contentController)
        contentController.didMoveToParentViewController(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.environment = RuntimeEnvironment()
        self.authController = AuthController(environment: environment)
        super.init(nibName: nil, bundle: nil)
        assert(false, "Not designed to be loaded via archive")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsContainer = UINavigationController(rootViewController: settingsController)!
        contentController.viewControllers = [settingsContainer]
        
        let hasCredentials = authController.hasCredentials()
        if !hasCredentials {
            let loginController = LoginViewController(authController: authController, delegate : self)
            
            addChildViewController(loginController)
            loginController.didMoveToParentViewController(self)
            
            showChildController(loginController)
        }
        else {
            showChildController(contentController)
        }
        
    }
    
    func showChildController(controller : UIViewController) {
        currentController = controller
        controller.view.frame = self.view.bounds
        view.addSubview(controller.view)
    }
    
    override func viewDidLayoutSubviews() {
        currentController?.view.frame = self.view.bounds
    }
    
    func loginControllerSucceeded(controller: LoginViewController) {
        transitionFromViewController(controller, toViewController: contentController, duration: 0.2, options: .TransitionCrossDissolve, animations: {}, completion: nil)
        currentController = contentController
        controller.removeFromParentViewController()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func signOut() {
        self.authController.signOut()
        
        let loginController = LoginViewController(authController: authController, delegate: self)
        addChildViewController(loginController)
        loginController.didMoveToParentViewController(self)
        
        transitionFromViewController(contentController, toViewController: loginController, duration: 0.2, options: .TransitionCrossDissolve, animations: {}, completion: nil)
        currentController = loginController
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return currentController
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return currentController
    }
}
