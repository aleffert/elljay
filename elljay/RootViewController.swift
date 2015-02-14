//
//  RootViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/20/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

private typealias RootRouter = protocol<
    LoginViewControllerDelegate,
    SettingsViewControllerDelegate>


public class RootViewController: UIViewController, RootRouter {
    public struct Environment {
        public let authSession : AuthSession
        public let dataStore : DataStore
        public let networkService : NetworkService
        public let ljservice : LJService
        
        public init() {
            let ljservice = LJService()
            let keychain = KeychainService(serviceName: ljservice.serviceName)
            let dataStore = DataStore()
            self.init(dataStore : dataStore, keychain : keychain, ljservice : ljservice)
        }
        
        public init(dataStore : DataStore, keychain : KeychainServicing, ljservice : LJService) {
            self.dataStore = dataStore
            self.ljservice = ljservice
            authSession = AuthSession(keychain: keychain)
            let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: AuthorizedURLSessionDelegate(authSession: authSession), delegateQueue: NSOperationQueue.mainQueue())
            networkService = NetworkService(session: urlSession, challengeGenerator: ljservice)
        }
    }
    private class AuthenticatedViewInfo {
        let contentController = UITabBarController()
        let settingsController : SettingsViewController
        let feedController : FeedViewController
        
        init(credentials : AuthCredentials, environment : Environment, router : RootRouter) {
            let dataStore = DataStore()
            let networkService = AuthenticatedNetworkService(service: environment.networkService, credentials: credentials)
            let dataVendor = DataSourceVendor(environment:
                DataSourceVendor.Environment(
                    dataStore: environment.dataStore,
                    ljservice: environment.ljservice,
                    networkService: networkService
                )
            )
            feedController = FeedViewController(environment:
                FeedViewController.Environment(
                    dataVendor: dataVendor,
                    ljservice: environment.ljservice,
                    networkService: networkService
                )
            )
            settingsController = SettingsViewController(environment :
                SettingsViewController.Environment(delegate: router)
            )
            let settingsContainer = UINavigationController(rootViewController: settingsController)
            let feedContainer = UINavigationController(rootViewController: feedController)
            contentController.viewControllers = [feedContainer, settingsContainer]
        }
    }
    
    private let environment : Environment
    private let authController : AuthController
    private var authenticatedViewInfo : AuthenticatedViewInfo?
    
    var currentController : UIViewController?
    
    public init(environment : Environment) {
        self.environment = environment
        
        let authEnvironment =
        AuthController.Environment(authSession: environment.authSession,
            ljservice: environment.ljservice,
            networkService: environment.networkService)
        
        self.authController = AuthController(environment: authEnvironment)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("Not designed to be loaded via archive")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let credentials = authController.credentials {
            let info = AuthenticatedViewInfo(credentials : credentials, environment : environment, router : self)
            showChildController(info.contentController)
            authenticatedViewInfo = info
        }
        else {
            let loginController = freshLoginViewController()
            
            addChildViewController(loginController)
            loginController.didMoveToParentViewController(self)
            
            showChildController(loginController)
        }
        
    }
    
    public override func viewDidLayoutSubviews() {
        currentController?.view.frame = self.view.bounds
    }
    
    private func freshLoginViewController() -> LoginViewController {
        return LoginViewController(
            environment: LoginViewController.Environment(
                delegate: self,
                authController: authController
            ))
    }

    private func showChildController(controller : UIViewController) {
        addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        currentController = controller
        controller.view.frame = self.view.bounds
        view.addSubview(controller.view)
    }
    private func transitionToChildController(controller : UIViewController) {
        addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        transitionFromViewController(currentController!, toViewController: controller, duration: 0.2, options: .TransitionCrossDissolve, animations: {}, completion: nil)
        
        currentController?.willMoveToParentViewController(nil)
        currentController?.removeFromParentViewController()
        currentController = controller
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func loginSucceeded(#credentials : AuthCredentials) {
        let info = AuthenticatedViewInfo(credentials: credentials, environment: environment, router: self)
        authenticatedViewInfo = info
        transitionToChildController(info.contentController)
    }
    
    private func signOut() {
        self.authController.signOut()
        
        let loginController = freshLoginViewController()

        transitionToChildController(loginController)
    }
    
    public func loginControllerSucceeded(controller: LoginViewController, credentials : AuthCredentials) {
        loginSucceeded(credentials : credentials)
    }
    
    func signOut(#fromController: SettingsViewController) {
        signOut()
    }
    
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return currentController
    }
    
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return currentController
    }
    
}

// Only for use in tests
extension RootViewController {
    public func t_showingLoginView() -> Bool {
        return currentController?.isKindOfClass(LoginViewController.classForCoder()) ?? false
    }
    
    public func t_showingAuthenticatedView() -> Bool {
        return currentController?.isKindOfClass(UITabBarController.classForCoder()) ?? false
    }
    
    public func t_login(credentials : AuthCredentials) {
        loginSucceeded(credentials : credentials)
    }
    
    public func t_signOut() {
        signOut()
    }
}