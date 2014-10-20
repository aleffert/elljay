//
//  AuthController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/31/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

typealias AuthControllerEnvironment = protocol<AuthSessionOwner, NetworkServiceOwner, LJServiceOwner>

// todo make a class variable
let AuthControllerBadCredentialsNotification = "AuthControllerBadCredentialsNotification"

class AuthController {
    
    private let environment : AuthControllerEnvironment
    
    init (environment : AuthControllerEnvironment) {
        self.environment = environment
    }
    
    func hasCredentials () -> Bool {
        if environment.authSession.hasCredentials {
            return true
        }
        
        environment.authSession.loadFromKeychainIfPossible()
        return environment.authSession.hasCredentials
    }
    
    func attemptLogin(username : String, password : String, completion : (success : Bool, NSError?) -> Void) {
        let sessionInfo = AuthSessionInfo(username: username, password: password)
        
        let loginRequest = self.environment.ljservice.login()
        self.environment.networkService.send(sessionInfo: sessionInfo, request: loginRequest) { (loginResponse, urlResponse, error) in
            if let l = loginResponse {
                self.environment.authSession.store(sessionInfo)
                self.environment.authSession.saveToKeychain()
                completion(success : true, nil)
            }
            else {
                completion(success : false, error)
            }
        }

    }
    
    func signOut() {
        self.environment.authSession.clear()
    }

}
