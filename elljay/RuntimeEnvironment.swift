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
    private(set) var authSession : AuthSession // this really wants to be a let, but it seems to trigger a compiler bug
    let networkService : NetworkService
    let ljservice : LJService
    
    init() {
        ljservice = LJService()
        authSession = AuthSession(keychain: KeychainService(serviceName: ljservice.name))
        networkService = NetworkService()
    }
}
