//
//  RuntimeEnvironment.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

class RuntimeEnvironment:
    AuthSessionOwner,
    AuthenticatedNetworkServiceOwner,
    NetworkServiceOwner,
    LJServiceOwner
{
    let authSession : AuthSession
    let networkService : NetworkService
    let ljservice : LJService
    
    init() {
        ljservice = LJService()
        let urlSession = NSURLSession.sharedSession()
        let keychainService = KeychainService(serviceName: ljservice.name)
        authSession = AuthSession(keychain: keychainService, urlSession : urlSession)
        networkService = NetworkService(session: urlSession, challengeGenerator: ljservice)
    }
    
    var authenticatedNetworkService : AuthenticatedNetworkService? {
        return authSession.storage.map { AuthenticatedNetworkService(service: self.networkService, sessionInfo: $0)
        }
    }
}
