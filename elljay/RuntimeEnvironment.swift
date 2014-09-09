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
    LJServiceOwner
{
    let authSession : AuthSession
    let networkService : NetworkService
    let ljservice : LJService
    
    init() {
        ljservice = LJService()
        authSession = AuthSession(keychain: KeychainService(serviceName: ljservice.name))
        networkService = NetworkService()
    }
}
