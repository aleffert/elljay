//
//  Service.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

public struct Request<A, B> {
    public let urlRequest : B -> NSURLRequest
    public let parser : NSData -> Result<A>
}

public typealias ChallengeInfo = (credentials : AuthCredentials, challenge : String)


// The LJ API has a year 2038 bug. Sigh
private extension Int32 {
    func dateFromUnixSeconds() -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(self))
    }
}

public struct DateUtils {
    
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
            formatter.locale = NSLocale.usEnglishLocale()
            return formatter
    }
    
    public static func stringFromDate(date : NSDate) -> String {
        return standardFormatter.stringFromDate(date)
    }
    
    public static func dateFromString(string : String) -> NSDate? {
        return standardFormatter.dateFromString(string)
    }

    private static var feedFormat : NSString {
        return "EEE, dd MMMM yyyy HH:mm:ss Z"
    }

    private static var feedDateFormatter : NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = feedFormat
        formatter.locale = NSLocale.usEnglishLocale()
        return formatter
    }

    private static func feedDateFromString(string : String) -> NSDate? {
        return feedDateFormatter.dateFromString(string)
    }
}

public struct GetChallengeResponse {
    public let challenge : String
    public let expireTime : NSDate
    public let serverTime : NSDate
}

public protocol ChallengeRequestable {
    func getChallenge() -> (NSURLRequest, NSData -> Result<GetChallengeResponse>)
}

private let LJServiceVersion : Int32 = 1


// TODO change to a class variable once they're supported
public let LJServiceErrorDomain = "com.akivaleffert.elljay.LJService"
public let LJServiceErrorMalformedResponseCode = -100

public class LJService : ChallengeRequestable {
    private class func serviceURL() -> NSURL {
        return NSURL(scheme: "https", host: "livejournal.com", path: "/interface/xmlrpc")!
    }
    
    let serviceName = "LiveJournal!"

    public init() {
    }
    
    private func malformedResponseError(description : String) -> NSError {
        return NSError(domain : LJServiceErrorDomain, code : LJServiceErrorMalformedResponseCode, userInfo : [NSLocalizedDescriptionKey : description])
    }
    
    private func XMLRPCURLRequest(#name : String, params : [String : XMLRPCParam]) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: LJService.serviceURL())
        let paramStruct = XMLRPCParam.XStruct(params)
        request.setupXMLRPCCall(path: "LJ.XMLRPC." + name, parameters: [paramStruct])
        return request
    }
    
    func wrapXMLRPCParser<A>(parser : XMLRPCParam -> A?) -> (NSData -> Result<A>) {
        let dataParser : NSData -> Result<A> = {data in
            let result = XMLRPCParser().from(data:NSMutableData(data:data))
            return result.bind {params -> Result<A> in
                if countElements(params) > 0 {
                    let parsed = parser(params[0])
                    if let p = parsed {
                        return Success(p)
                    }
                    else {
                        return Failure(self.malformedResponseError("Bad Response"))
                    }
                }
                else {
                    return Failure(self.malformedResponseError("Empty Body"))
                }
            }
        }
        return dataParser
    }

    private func authenticatedXMLRPCRequest<A>(#name : String, params : [String : XMLRPCParam], parser : XMLRPCParam -> A?) -> Request<A, ChallengeInfo> {
        let generator : (sessionInfo : AuthCredentials, challenge : String) -> NSURLRequest = {(sessionInfo, challenge) in
            var finalParams = params
            finalParams["ver"] = XMLRPCParam.XInt(LJServiceVersion)
            finalParams["username"] = XMLRPCParam.XString(sessionInfo.username)
            finalParams["auth_challenge"] = XMLRPCParam.XString(challenge)
            finalParams["auth_response"] = XMLRPCParam.XString(sessionInfo.challengeResponse(challenge))
            finalParams["auth_method"] = XMLRPCParam.XString("challenge")
            
            return self.XMLRPCURLRequest(name: name, params: finalParams)
        }
        return Request(urlRequest: generator, parser: wrapXMLRPCParser(parser))
    }
    
    public func getChallenge() -> (NSURLRequest, NSData -> Result<GetChallengeResponse>) {
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
        return (XMLRPCURLRequest(name: "getchallenge", params: [:]), wrapXMLRPCParser(parser))
    }

    public struct LoginResponse {
        public let fullname : String
    }

    public func login() -> Request<LoginResponse, ChallengeInfo> {
        let parser : XMLRPCParam -> LoginResponse? = {x in
            let response = x.structBody()
            let fullname = response?["fullname"]?.stringBody()
            if fullname == nil {
                return nil
            }
            return LoginResponse(fullname : fullname!)
        }

        // TODO all the login options
        return authenticatedXMLRPCRequest(name: "login", params: [:], parser: parser)
    }
    
    public enum SyncAction {
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
    
    public enum SyncType {
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
    
    
    public struct SyncItem {
        public let action : SyncAction
        public let item : (type : SyncType, index : Int32)
        public let time : NSDate
        
        private static func from(#param : XMLRPCParam) -> SyncItem? {
            let body = param.structBody()?
            let action = body?["action"]?.stringBody().bind{ SyncAction.from(string: $0) }
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
    
    public struct SyncItemsResponse {
        public let syncitems : [SyncItem]
        public let count : Int32
        public let total : Int32

    }
    
    public func syncitems(lastSync : NSDate? = nil) -> Request<SyncItemsResponse, ChallengeInfo> {
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
        
        return authenticatedXMLRPCRequest(name: "syncitems", params : params, parser : parser)
    }
    
    public typealias Username = String
    
    public struct Friend {
        public let user : Username
        public let name : String?
        
        public init(user : Username, name : String?) {
            self.user = user
            self.name = name
        }
        
        public var displayName : String {
            return name ?? user
        }
    }
    
    public struct GetFriendsResponse {
        public let friends : [Friend]
    }

    public func getfriends() -> Request<GetFriendsResponse, ChallengeInfo> {
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
        return authenticatedXMLRPCRequest(name: "getfriends", params: [:], parser: parser)
    }

    public struct Entry {
        public let title : String?
        public let author : Username
        public let date : NSDate
        public let tags : [String]
        
        public init(title : String?, author : Username, date : NSDate, tags : [String]) {
            self.title = title
            self.author = author
            self.date = date
            self.tags = tags
        }
    }
    
    public struct FeedResponse {
        public let entries : [Entry]
    }

    private func feedURL(#username : String) -> NSURL {
        let args = "?auth=digest"
        if countElements(username) > 0 && username.hasPrefix("_") {
            return NSURL(scheme: "http", host:"users.livejournal.com", path:"\(username)/data/rss\(args)")!
        }
        else {
            return NSURL(scheme: "http", host:"\(username).livejournal.com", path:"/data/rss\(args)")!
        }
    }

    public func feed(username : String) -> Request<FeedResponse, AuthCredentials> {
        let generator = {(sessionInfo : AuthCredentials) -> NSURLRequest in
            let url = self.feedURL(username : sessionInfo.username)
            let request = NSMutableURLRequest(URL: url)
            return NSURLRequest(URL:url)
        }
        
        let parser = {(data : NSData) -> Result<FeedResponse> in
            let document = XMLParser().parse(data)
            let entries = document.bind {d -> Result<[Entry]> in
                let items = d.body[0].child("channel")?.all("item")
                let entries = items.bind {(items : [XMLNode]) -> [Entry]? in return items.mapOrFail {i in
                    let title = i.child("title")?.innerText
                    let date = i.child("pubDate")?.innerText.bind { DateUtils.feedDateFromString($0) }
                    let tags = i.all("category").flatMap { $0.innerText }
                    return date.map { Entry(
                        title : title,
                        author : username,
                        date : $0,
                        tags : tags) }
                }}
                if let e = entries {
                    return Success(e)
                }
                else {
                    return Failure(self.malformedResponseError("Invalid RSS"))
                }
            }
            return entries.map{ FeedResponse(entries:$0) }
        }
        return Request(urlRequest : generator, parser : parser)
    }

}
