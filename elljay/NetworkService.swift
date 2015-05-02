//
//  XMLRPCService.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import CFNetwork
import UIKit

public protocol NetworkTask {
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

public let NetworkServiceErrorDomain = "com.akivaleffert.elljay.NetworkService"

public class NetworkService {
    private let errorMalformedResponseDescription = "The response from the server was malformed"

    private let session : NSURLSession
    private let challengeGenerator : ChallengeRequestable
    
    public convenience init() {
        let session = NSURLSession.sharedSession()
        let challengeGenerator = LJService()
        self.init(session : session, challengeGenerator: challengeGenerator)
    }

    public init(session : NSURLSession, challengeGenerator : ChallengeRequestable) {
        self.session = session
        self.challengeGenerator = challengeGenerator
    }

    public func sendRequest<A>(urlRequest : NSURLRequest, parser : NSData -> Result<A>, completionHandler : (Result<A> , NSURLResponse!) -> Void) -> NetworkTask {
        let wrappedCompletion = {(result, response) in
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(result, response)
            }
        }
        let result = session.dataTaskWithRequest(urlRequest) {(result : NSData!, response : NSURLResponse!, error : NSError?) in
            if let e = error {
                wrappedCompletion(.Failure(e), response)
            }
            else {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if statusCode == 200 {
                    wrappedCompletion(parser(result), response)
                }
                else {
                    let e = NSError(domain : NetworkServiceErrorDomain, code : statusCode, userInfo : [:])
                    wrappedCompletion(.Failure(e), response)
                }
            }
        }
        
        result.resume()
        return result
    }
    
    public func sendRequest<A>(request : Request<A, ChallengeInfo>, credentials : AuthCredentials,  completionHandler : (Result<A>, NSURLResponse!) -> Void) -> NetworkTask {
        let (challengeRequest : NSURLRequest, parser : NSData -> Result<GetChallengeResponse>) = challengeGenerator.getChallenge()
        var groupTask : ChallengeRequestTask? = nil
        let task = sendRequest(challengeRequest, parser: parser) {[weak groupTask] (response, urlResponse) -> Void in
            switch(response) {
            case let .Success(c):
                let urlRequest = request.urlRequest(credentials: credentials, challenge: c.value.challenge)
                let task = self.sendRequest(urlRequest, parser: request.parser, completionHandler: completionHandler)
                groupTask?.currentTask = task
            case let .Failure(e):
                completionHandler(.Failure(e), urlResponse)
            }
        }
        groupTask = ChallengeRequestTask(task : task)
        
        return groupTask!
    }
    
    func send<A>(#credentials : AuthCredentials, request : Request<A, AuthCredentials>, completionHandler : (Result<A>, NSURLResponse!) -> Void) -> NetworkTask {
        let urlRequest = request.urlRequest(credentials)
        return self.sendRequest(urlRequest, parser: request.parser, completionHandler: completionHandler)
    }

}
