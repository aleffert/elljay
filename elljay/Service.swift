//
//  Service.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

struct Request<Result> {
    let urlRequest : NSURLRequest
    let parser : XMLRPCParam -> Result?
}

// The LJ API has a year 2038 bug. Sigh
private extension Int32 {
    func dateFromUnixSeconds() -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(self))
    }
}

class Service {
    let url = NSURL(scheme: "https", host: "livejournal.com", path: "/interface/xmlrpc")
    let name = "LiveJournal!"

    init() {
    }

    private func request<A>(#name : String, params : [String : XMLRPCParam], parser : XMLRPCParam -> A?) -> Request<A> {
        let request = NSMutableURLRequest(URL: url)
        let paramStruct = XMLRPCParam.XStruct(params)
        println("params are " + paramStruct.toXMLNode().description)
        request.setupXMLRPCCall(path: "LJ.XMLRPC." + name, parameters: [paramStruct])
        return Request(urlRequest: request, parser: parser)
    }

    struct GetChallengeResponse {
        let challenge : String
        let expireTime : NSDate
        let serverTime : NSDate
    }
    
    func getChallenge() -> Request<GetChallengeResponse> {
        let parser : XMLRPCParam -> GetChallengeResponse? = {x in
            let response = x.structBody()
            let challenge = response?["challenge"]?.stringBody()
            let expireTime = response?["expire_time"]?.intBody()?.dateFromUnixSeconds()
            let serverTime = response?["server_time"]?.intBody()?.dateFromUnixSeconds()
            if challenge == nil || expireTime == nil && serverTime == nil {
                return nil
            }
            return GetChallengeResponse(challenge : challenge!, expireTime : expireTime!, serverTime : serverTime!)
        }
        return request(name : "getchallenge", params : [:], parser: parser)
    }

    func parametersForSession(sessionInfo : AuthSessionInfo) -> [String : XMLRPCParam] {
        return [
            "username" : XMLRPCParam.XString(sessionInfo.username),
            "auth_challenge" : XMLRPCParam.XString(sessionInfo.challenge),
            "auth_response" : XMLRPCParam.XString(sessionInfo.challengeResponse),
            "auth_method" : XMLRPCParam.XString("challenge")
        ]
    }

    struct LoginResponse {
        let fullname : String
    }

    func login(sessionInfo : AuthSessionInfo) -> Request<LoginResponse> {
        let parser : XMLRPCParam -> LoginResponse? = {x in
            let response = x.structBody()
            let fullname = response?["fullname"]?.stringBody()
            if fullname == nil {
                return nil
            }
            return LoginResponse(fullname : fullname!)
        }
        let params = parametersForSession(sessionInfo)

        return request(name: "login", params: params, parser: parser)
    }

   
}


protocol ServiceOwner {
    var service : Service {get}
}
