//
//  RootViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/20/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

typealias AppRouter = protocol<LoginViewControllerDelegate, SettingsViewControllerDelegate>

private class AuthenticatedViewInfo {
    let contentController = UITabBarController()
    let settingsController : SettingsViewController
    let feedController : FeedViewController
    
    init(credentials : AuthCredentials, environment : RootEnvironment, router : AppRouter) {
        let dataStore = DataStore()
        let networkService = AuthenticatedNetworkService(service: environment.networkService, credentials: credentials)
        let dataVendor = DataSourceVendor(networkService : networkService, dataStore : dataStore)
        feedController = FeedViewController(environment:
            FeedViewControllerEnvironment(
                ljservice: environment.ljservice,
                networkService: networkService,
                dataVendor: dataVendor)
        )
        settingsController = SettingsViewController(environment :
            SettingsViewControllerEnvironment(delegate: router)
        )
    }
}

public struct RootEnvironment {
    public let authSession : AuthSession
    public let networkService : NetworkService
    public let ljservice : LJService
    
    public init() {
        let ljservice = LJService()
        let keychain = PersistentKeychainService(serviceName: ljservice.serviceName)
        self.init(ljservice : ljservice, keychain : keychain)
    }
    
    public init(ljservice : LJService, keychain : KeychainService) {
        self.ljservice = ljservice
        authSession = AuthSession(keychain: keychain)
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: AuthorizedURLSessionDelegate(authSession: authSession), delegateQueue: NSOperationQueue.mainQueue())
        networkService = NetworkService(session: urlSession, challengeGenerator: ljservice)
    }
}

public class RootViewController: UIViewController, AppRouter {
    private let environment : RootEnvironment
    private let authController : AuthController
    private var authenticatedViewInfo : AuthenticatedViewInfo?
    
    var currentController : UIViewController?
    
    public init(environment : RootEnvironment) {
        self.environment = environment
        
        let authEnvironment =
        AuthControllerEnvironment(authSession: environment.authSession,
            ljservice: environment.ljservice,
            networkService: environment.networkService)
        
        self.authController = AuthController(environment: authEnvironment)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("Not designed to be loaded via archive")
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let credentials = authController.credentials {
            let info = freshAuthenticatedController(credentials : credentials)
            showChildController(info.contentController)
            authenticatedViewInfo = info
        }
        else {
            let loginController = LoginViewController(authController: authController, delegate : self)
            
            addChildViewController(loginController)
            loginController.didMoveToParentViewController(self)
            
            showChildController(loginController)
        }
        
    }
    
    private func freshAuthenticatedController(#credentials : AuthCredentials) -> AuthenticatedViewInfo {
        let info = AuthenticatedViewInfo(credentials: credentials, environment: environment, router : self)
        let settingsContainer = UINavigationController(rootViewController: info.settingsController)
        let feedContainer = UINavigationController(rootViewController: info.feedController)
        info.contentController.viewControllers = [feedContainer, settingsContainer]
        
        return info
    }
    
    func showChildController(controller : UIViewController) {
        controller.willMoveToParentViewController(self)
        addChildViewController(controller)
        currentController = controller
        controller.view.frame = self.view.bounds
        view.addSubview(controller.view)
    }
    
    public override func viewDidLayoutSubviews() {
        currentController?.view.frame = self.view.bounds
    }
    
    func loginSucceeded(#credentials : AuthCredentials) {
        let info = freshAuthenticatedController(credentials: credentials)
        authenticatedViewInfo = info
        addChildViewController(info.contentController)
        transitionFromViewController(currentController!, toViewController: info.contentController, duration: 0.2, options: .TransitionCrossDissolve, animations: {}, completion: nil)
        currentController?.removeFromParentViewController()
        currentController = info.contentController
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func signOut() {
        self.authController.signOut()
        
        let loginController = LoginViewController(authController: authController, delegate: self)
        addChildViewController(loginController)
        loginController.didMoveToParentViewController(self)
        
        transitionFromViewController(authenticatedViewInfo!.contentController,
            toViewController: loginController,
            duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: {},
            completion: nil)
        currentController?.removeFromParentViewController()
        currentController = loginController
        authenticatedViewInfo = nil
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func loginControllerSucceeded(controller: LoginViewController, credentials : AuthCredentials) {
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