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
    XMLRPCServiceOwner,
    ServiceOwner
{
    let authSession : AuthSession
    let networkService : XMLRPCService
    let service : Service
    
    init() {
        service = Service()
        authSession = AuthSession(keychain: KeychainService(serviceName: service.name))
        networkService = XMLRPCService()
    }
}
