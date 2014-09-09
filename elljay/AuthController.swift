//
//  AuthController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/31/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

typealias AuthControllerEnvironment = protocol<AuthSessionOwner, NetworkServiceOwner, ServiceOwner>

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
        let loginRequest = self.environment.service.login()
        // challenge succeeded so attempt to login
        let sessionInfo = AuthSessionInfo(username: username, password: password, challenge: "")
        
        self.environment.networkService.send(sessionInfo: sessionInfo, request: loginRequest) { (loginResponse, urlResponse, error) in
            if let l = loginResponse {
                completion(success : true, nil)
            }
            else {
                completion(success : false, error)
            }
        }
        
        let syncRequest = self.environment.service.syncitems()
        self.environment.networkService.send(sessionInfo: sessionInfo, request: syncRequest) { (syncResponse, urlResponse, error) in
            println("countItems is \(syncResponse?.count)")
            println("totalItems is \(syncResponse?.total)")
        }

    }

}
