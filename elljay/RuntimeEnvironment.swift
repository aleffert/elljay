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
    NetworkServiceOwner,
    ServiceOwner
{
    let authSession : AuthSession
    let networkService : NetworkService
    let service : Service
    
    init() {
        service = Service()
        authSession = AuthSession(keychain: KeychainService(serviceName: service.name))
        networkService = NetworkService()
    }
}
