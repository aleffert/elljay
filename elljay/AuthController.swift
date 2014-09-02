//
//  AuthController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/31/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

typealias AuthControllerEnvironment = protocol<AuthSessionOwner, XMLRPCServiceOwner, ServiceOwner>

// todo make a class variable
let AuthControllerBadCredentialsNotification = "AuthControllerBadCredentialsNotification"

class AuthController {
    
    private let environment : AuthControllerEnvironment
    
    init (environment : AuthControllerEnvironment) {
        self.environment = environment
    }
    
    func refreshExistingCredentials(storage : AuthSessionInfo) {
        let challengeRequest = environment.service.getChallenge()
        environment.networkService.send(request: challengeRequest) { (challengeResponse, urlResponse, error) in
            if let c = challengeResponse {
                self.environment.authSession.update(challenge : c.challenge, challengeExpiration:c.expireTime)
            }
            // on failure, do nothing. There may be a temporary server issue
            
            // TODO: Show an error
        }
    }
    
    func hasCredentials () -> Bool {
        if environment.authSession.hasCredentials {
            return true
        }
        
        environment.authSession.loadFromKeychainIfPossible()
        return environment.authSession.hasCredentials
    }
    
    func checkCredentialsUpdatingIfNecessary() -> Bool {
        if hasCredentials() {
            return true
        }
        else if environment.authSession.hasExpiredChallenge {
            environment.authSession.storage.bind {s in
                self.refreshExistingCredentials(s)
            }
            return true
        }
        return false
    }
    
    func attemptLogin(username : String, password : String, completion : (success : Bool, NSError?) -> Void) {
        // first, get a challenge
        let challengeRequest = environment.service.getChallenge()
        environment.networkService.send(request: challengeRequest) { (challengeResponse, urlResponse, error) in
            if let c = challengeResponse {
                let authSession = AuthSessionInfo(username: username, password: password, challenge: c.challenge, challengeExpiration: c.expireTime)
                
                let loginRequest = self.environment.service.login(authSession)
                // challenge succeeded so attempt to login
                self.environment.networkService.send(request: loginRequest) { (loginResponse, urlResponse, error) in
                    if let l = loginResponse {
                        println("got response " + l.fullname)
                        completion(success : true, nil)
                    }
                    else {
                        completion(success : false, error)
                    }
                }
            }
            else {
                completion(success : false, error)
            }
        }
        
    }

}
