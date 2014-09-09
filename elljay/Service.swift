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
    let urlRequest : AuthSessionInfo -> NSURLRequest
    let parser : XMLRPCParam -> Result?
}

// The LJ API has a year 2038 bug. Sigh
private extension Int32 {
    func dateFromUnixSeconds() -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(self))
    }
}

private extension NSDate {
    
    private func elljayStandardTimeZone() -> NSTimeZone {
        // TODO figure this out. I'm hoping it's GMT
        return NSTimeZone(forSecondsFromGMT: 0)
    }
    
    func elljayStandardDateString() -> NSString {
        let formatter = NSDateFormatter()
        formatter.timeZone = elljayStandardTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.stringFromDate(self)
    }
}

struct GetChallengeResponse {
    let challenge : String
    let expireTime : NSDate
    let serverTime : NSDate
}

protocol ChallengeRequestable {
    func getChallenge() -> (NSURLRequest, XMLRPCParam -> GetChallengeResponse?)
}

class Service : ChallengeRequestable {
    let url = NSURL(scheme: "https", host: "livejournal.com", path: "/interface/xmlrpc")
    let name = "LiveJournal!"

    init() {
    }

    
    private func urlRequest(#name : String, params : [String : XMLRPCParam]) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: self.url)
        let paramStruct = XMLRPCParam.XStruct(params)
        request.setupXMLRPCCall(path: "LJ.XMLRPC." + name, parameters: [paramStruct])
        return request
    }

    private func authenticatedRequest<A>(#name : String, params : [String : XMLRPCParam], parser : XMLRPCParam -> A?) -> Request<A> {
        let generator : AuthSessionInfo -> NSURLRequest = {sessionInfo in
            var finalParams = params
            finalParams["ver"] = XMLRPCParam.XInt(1)
            finalParams["username"] = XMLRPCParam.XString(sessionInfo.username)
            finalParams["auth_challenge"] = XMLRPCParam.XString(sessionInfo.challenge)
            finalParams["auth_response"] = XMLRPCParam.XString(sessionInfo.challengeResponse)
            finalParams["auth_method"] = XMLRPCParam.XString("challenge")
            
            return self.urlRequest(name: name, params: finalParams)
        }
        return Request(urlRequest: generator, parser: parser)
    }

    
    func getChallenge() -> (NSURLRequest, XMLRPCParam -> GetChallengeResponse?) {
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
        return (urlRequest(name: "getchallenge", params: [:]), parser)
    }

    struct LoginResponse {
        let fullname : String
    }

    func login() -> Request<LoginResponse> {
        let parser : XMLRPCParam -> LoginResponse? = {x in
            let response = x.structBody()
            let fullname = response?["fullname"]?.stringBody()
            if fullname == nil {
                return nil
            }
            return LoginResponse(fullname : fullname!)
        }

        // TODO all the login options
        return authenticatedRequest(name: "login", params: [:], parser: parser)
    }
    
    enum SyncAction {
        case Create
        case Update
    }
    
    struct SyncItem {
        let type : String
        let item : String
        let time : NSDate
    }
    
    struct SyncItemsResponse {
        let syncitems : [SyncItem]
        let count : Int32
        let total : Int32
    }
    
    func syncitems(lastSync : NSDate? = nil) -> Request<SyncItemsResponse> {
        let parser : XMLRPCParam -> SyncItemsResponse? = {x in
            let response = x.structBody()
            let total = response?["total"]?.intBody()
            let count = response?["count"]?.intBody()
            let syncItemsBody = response?["syncitems"]?.arrayBody()
            let syncitems : [SyncItem]? = syncItemsBody?.mapOrFail{p in
                let body = p.structBody()?
                let type = body?["type"]?.stringBody()
                let item = body?["item"]?.stringBody()
                if(item == nil || type == nil) {
                    return nil
                }
                return SyncItem(type: type!, item: item!, time: NSDate())
            }
            if total == nil || count == nil || syncitems == nil{
                return nil
            }
            return SyncItemsResponse(syncitems: syncitems!, count: count!, total: total!)
        }
        var params : [String : XMLRPCParam] = [:]
        if let d = lastSync {
            params["lastsync"] = XMLRPCParam.XString(d.elljayStandardDateString())
        }
        
        return authenticatedRequest(name: "syncitems", params : params, parser : parser)
    }

}


protocol ServiceOwner {
    var service : Service {get}
}
