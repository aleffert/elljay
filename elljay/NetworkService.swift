//
//  XMLRPCService.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import CFNetwork
import UIKit

protocol NetworkTask {
    func cancel() -> ()
}

extension NSURLSessionTask : NetworkTask {
}

class ChallengeRequestTask : NetworkTask {
    var currentTask : NetworkTask
    
    init(task : NetworkTask) {
        currentTask = task
    }
    
    func cancel() {
        currentTask.cancel()
    }
}


// TODO change to a class variable once they're supported
let NetworkServiceErrorDomain = "com.akivaleffert.elljay.NetworkService"
let NetworkServiceErrorMalformedResponseCode = -100

class NetworkService {
    private let errorMalformedResponseDescription = "The response from the server was malformed"

    private let session : NSURLSession
    private let challengeGenerator : ChallengeRequestable
    
    convenience init() {
        let session = NSURLSession.sharedSession()
        let challengeGenerator = Service()
        self.init(session : session, challengeGenerator: challengeGenerator)
    }

    init(session : NSURLSession, challengeGenerator : ChallengeRequestable) {
        self.session = session
        self.challengeGenerator = challengeGenerator
    }

    private func malformedResponseError() -> NSError {
        return NSError(domain : NetworkServiceErrorDomain, code : NetworkServiceErrorMalformedResponseCode, userInfo : [NSLocalizedDescriptionKey : errorMalformedResponseDescription])
    }

    private func sendRequest<A>(#urlRequest : NSURLRequest, parser : XMLRPCParam -> A?, completionHandler : (A? , NSURLResponse!, NSError?) -> Void) -> NetworkTask {
        let result = session.dataTaskWithRequest(urlRequest) {(result : NSData!, response : NSURLResponse!, error : NSError?) in
            if let e = error {
                completionHandler(nil, response, e)
            }
            else if let r = result {
                let params = XMLRPCResult.from(data: r)
                switch(params) {
                case let .Fault(error):
                    completionHandler(nil, response, error)
                case let .Response(params):
                    if countElements(params) > 0 {
                        let parsed = parser(params[0])
                        let error : NSError? = parsed == nil ? nil : self.malformedResponseError()
                        completionHandler(parsed, response, error)
                    }
                    else {
                        completionHandler(nil, response, error)
                    }
                case let .ParseError(e):
                    let error = self.malformedResponseError()
                    completionHandler(nil, response, error)
                }
            }
            else {
                completionHandler(nil, response, error)
            }
        }
        
        result.resume()
        return result
    }
    
    func send<A>(#sessionInfo : AuthSessionInfo, request : Request<A>, completionHandler : (A?, NSURLResponse!, NSError?) -> Void) -> NetworkTask {
        let (challengeRequest : NSURLRequest, parser : XMLRPCParam -> GetChallengeResponse?) = challengeGenerator.getChallenge()
        var groupTask : ChallengeRequestTask? = nil
        let task = sendRequest(urlRequest: challengeRequest, parser: parser) {[weak groupTask] (response, urlResponse, error) -> Void in
            if let c = response {
                let session = AuthSessionInfo(username: sessionInfo.username, password: sessionInfo.password, challenge: c.challenge)
                let urlRequest = request.urlRequest(sessionInfo)
                groupTask?.currentTask = self.sendRequest(urlRequest : urlRequest, request.parser, completionHandler)
            }
            else {
                completionHandler(nil, urlResponse, error)
            }
        }
        groupTask = ChallengeRequestTask(task : task)
        
        return groupTask!

    }

}

protocol NetworkServiceOwner {
    var networkService : NetworkService { get }
}