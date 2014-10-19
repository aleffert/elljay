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
    let urlRequest : (sessionInfo : AuthSessionInfo, challenge : String) -> NSURLRequest
    let parser : XMLRPCParam -> Result?
}

// The LJ API has a year 2038 bug. Sigh
private extension Int32 {
    func dateFromUnixSeconds() -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(self))
    }
}

struct DateUtils {
    
    static private func standardTimeZone() -> NSTimeZone {
        // TODO figure this out. I'm hoping it's GMT
        return NSTimeZone(forSecondsFromGMT: 0)
    }
    
    static private var standardFormat : NSString {
        return "yyyy-MM-dd HH:mm:ss"
    }
    
    static private var standardFormatter : NSDateFormatter {
        let formatter = NSDateFormatter()
            formatter.timeZone = standardTimeZone()
            formatter.dateFormat = standardFormat
            return formatter
    }
    
    static func stringFromDate(date : NSDate) -> String {
        return standardFormatter.stringFromDate(date)
    }
    
    static func dateFromString(string : String) -> NSDate? {
        return standardFormatter.dateFromString(string)
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

private let LJServiceVersion : Int32 = 1

class LJService : ChallengeRequestable {
    let url = NSURL(scheme: "https", host: "livejournal.com", path: "/interface/xmlrpc")!
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
        let generator : (sessionInfo : AuthSessionInfo, challenge : String) -> NSURLRequest = {(sessionInfo, challenge) in
            var finalParams = params
            finalParams["ver"] = XMLRPCParam.XInt(LJServiceVersion)
            finalParams["username"] = XMLRPCParam.XString(sessionInfo.username)
            finalParams["auth_challenge"] = XMLRPCParam.XString(challenge)
            finalParams["auth_response"] = XMLRPCParam.XString(sessionInfo.challengeResponse(challenge))
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
        
        private static func from(#string : String) -> SyncAction? {
            switch(string) {
            case "create": return .Create
            case "update" : return .Update
            default: return nil
            }
        }
    }
    
    enum SyncType {
        case Journal
        case Comment
        
        private static func from(#string : String) -> SyncType? {
            switch(string) {
            case "C" : return .Comment
            case "L" : return .Journal
            default : return nil
            }
        }
    }
    
    
    struct SyncItem {
        let action : SyncAction
        let item : (type : SyncType, index : Int32)
        let time : NSDate
        
        private static func from(#param : XMLRPCParam) -> SyncItem? {
            let body = param.structBody()?
            let action = body?["action"]?.stringBody().bind{s in SyncAction.from(string: s)}
            let itemParam = body?["item"]?.stringBody()
            let itemParts = itemParam.bind{i -> [String]? in
                let components = (i as NSString).componentsSeparatedByString("-") as [String]
                return components.count == 2 ? components : nil
            }
            let item : (type : SyncType, index : Int32)? = itemParts.bind {components in
                return SyncType.from(string : components[0])
                .bind {t in
                    let index = (components[1] as NSString).intValue
                    return (type : t, index : index)
                }
                
            }
            let time : NSDate? = body?["time"]?.stringBody().bind{d in return DateUtils.standardFormatter.dateFromString(d)}
            if(item == nil || action == nil || time == nil) {
                return nil
            }
            return SyncItem(action: action!, item: item!, time: time!)
        }
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
                return SyncItem.from(param : p)
            }
            if total == nil || count == nil || syncitems == nil {
                return nil
            }
            return SyncItemsResponse(syncitems: syncitems!, count: count!, total: total!)
        }
        var params : [String : XMLRPCParam] = [:]
        if let d = lastSync {
            params["lastsync"] = XMLRPCParam.XString(DateUtils.stringFromDate(d))
        }
        
        return authenticatedRequest(name: "syncitems", params : params, parser : parser)
    }
    
    struct Friend {
        let user : String
        let name : String?
    }
    
    struct GetFriendsResponse {
        let friends : [Friend]
    }

    func getfriends() -> Request<GetFriendsResponse> {
        let parser : XMLRPCParam -> GetFriendsResponse? = {x in
            let response = x.structBody()
            let friends : [Friend]? = response?["friends"]?.arrayBody()?.mapOrFail {b in
                let user = b.structBody()?["username"]?.stringBody()
                let name = b.structBody()?["fullname"]?.stringBody()
                return user.map {
                    return Friend(user : $0, name : name)
                }
            }
            return friends.map {
                GetFriendsResponse(friends : $0)
            }
        }
        return authenticatedRequest(name: "getfriends", params: [:], parser: parser)
    }
    
}


protocol LJServiceOwner {
    var ljservice : LJService {get}
}
