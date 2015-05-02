//
//  CredentialFactory.swift
//  elljay
//
//  Created by Akiva Leffert on 2/8/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

import elljay

class CredentialFactory {
    class func freshCredentials() -> AuthCredentials {
        return AuthCredentials(username : NSUUID().UUIDString, password : NSUUID().UUIDString)
    }
}
