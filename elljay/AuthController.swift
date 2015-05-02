//
//  AuthController.swift
//  elljay
//
//  Created by Akiva Leffert on 8/31/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

public protocol AuthControlling {
    var credentials : AuthCredentials? { get }
    func attemptLogin(#username : String, password : String, completion : (result : Result<AuthCredentials>) -> Void)
    func signOut()
}

public class AuthController : AuthControlling {
    public struct Environment {
        public let authSession : AuthSession
        public let ljservice : LJService
        public let networkService : NetworkService
        
        public init(authSession : AuthSession, ljservice : LJService, networkService : NetworkService) {
            self.authSession = authSession
            self.ljservice = ljservice
            self.networkService = networkService
        }
    }
    
    private let environment : Environment
    
    public init (environment : Environment) {
        self.environment = environment
    }
    
    public var credentials : AuthCredentials? {
        if let c = environment.authSession.credentials {
            return c
        }
        else {
            self.environment.authSession.loadFromKeychainIfPossible()
            return self.environment.authSession.credentials   
        }
    }
    
    public func attemptLogin(#username : String, password : String, completion : (result : Result<AuthCredentials>) -> Void) {
        let credentials = AuthCredentials(username: username, password: password)
        
        let loginRequest = self.environment.ljservice.login()
        self.environment.networkService.sendRequest(loginRequest, credentials: credentials) { (loginResponse, urlResponse) in
            let result = loginResponse.map {(l : LJService.LoginResponse) -> AuthCredentials in
                self.environment.authSession.store(credentials)
                self.environment.authSession.saveToKeychain()
                return credentials
            }
            completion(result: result)
        }

    }
    
    public func signOut() {
        self.environment.authSession.clear()
    }

}
