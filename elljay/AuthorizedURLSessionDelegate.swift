//
//  AuthorizedURLSessionDelegate.swift
//  elljay
//
//  Created by Akiva Leffert on 11/30/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit


class AuthorizedURLSessionDelegate : NSObject, NSURLSessionTaskDelegate {
    
    private let authSession : AuthSession
    
    init(authSession : AuthSession) {
        self.authSession = authSession;
        super.init()
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        let credential = authSession.credentials.bind {(s : AuthCredentials) -> NSURLCredential in
            return NSURLCredential(user: s.username, password: s.password, persistence: NSURLCredentialPersistence.None)
        }
        completionHandler(.UseCredential, credential)
    }
}