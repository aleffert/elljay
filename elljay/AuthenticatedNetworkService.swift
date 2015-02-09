//
//  AuthenticatedNetworkService.swift
//  elljay
//
//  Created by Akiva Leffert on 10/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

class AuthenticatedNetworkService {
    
    private let service : NetworkService
    private let credentials : AuthCredentials
    
    init(service : NetworkService, credentials : AuthCredentials) {
        self.service = service
        self.credentials = credentials
    }
    
    func send<A>(#request : Request<A, ChallengeInfo>, completionHandler : (Result<A>, NSURLResponse!) -> Void) -> NetworkTask {
        return self.service.send(credentials : self.credentials, request : request, completionHandler : completionHandler)
    }
    
    func send<A>(#request : Request<A, AuthCredentials>, completionHandler : (Result<A>, NSURLResponse!) -> Void) -> NetworkTask {
        return self.service.send(credentials : self.credentials, request : request, completionHandler : completionHandler)
    }
}
