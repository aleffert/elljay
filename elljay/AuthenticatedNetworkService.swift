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
    private let sessionInfo : AuthSessionInfo
    
    init(service : NetworkService, sessionInfo : AuthSessionInfo) {
        self.service = service
        self.sessionInfo = sessionInfo
    }
    
    func send<A>(#request : Request<A, ChallengeInfo>, completionHandler : (Result<A>, NSURLResponse!) -> Void) -> NetworkTask {
        return self.service.send(sessionInfo : self.sessionInfo, request : request, completionHandler : completionHandler)
    }
    
    func send<A>(#request : Request<A, AuthSessionInfo>, completionHandler : (Result<A>, NSURLResponse!) -> Void) -> NetworkTask {
        return self.service.send(sessionInfo : self.sessionInfo, request : request, completionHandler : completionHandler)
    }
}


protocol AuthenticatedNetworkServiceOwner {
    var authenticatedNetworkService : AuthenticatedNetworkService? {get}
}