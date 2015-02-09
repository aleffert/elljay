//
//  LJServiceTestHelpers.swift
//  elljay
//
//  Created by Akiva Leffert on 2/8/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

import elljay

class LJServiceTestHelpers {
    
    class func standardTestDate() -> NSDate {
        let components = NSDateComponents()
        components.month = 12
        components.day = 7
        components.year = 1983
        let date = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        return date
    }
    
    class func challenge() -> (date : NSDate, challenge : String, params : XMLRPCParam){
        let date = standardTestDate()
        let epochDate = Int32(date.timeIntervalSince1970)
        let challenge = "c0:1073113200:2831:60:2TCbFBYR72f2jhVDuowz:0fba728f5964ea54160a5b18317d92df"
        let params = XMLRPCParam.XStruct(
            [
                "challenge" : XMLRPCParam.XString(challenge),
                "expire_time" : XMLRPCParam.XInt(epochDate),
                "server_time" : XMLRPCParam.XInt(epochDate)
            ])
        return (date, challenge, params)
    }
    
    class func XMLRPCRequestsMatch(lhs : NSURLRequest, _ rhs : NSURLRequest) -> Bool {
        return lhs.URL == rhs.URL && lhs.XMLRPCMethod() == rhs.XMLRPCMethod()
    }
    
    class func stubChallenge() {
        let service = LJService()
        let urlRequest = service.getChallenge()
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return self.XMLRPCRequestsMatch(request, urlRequest.0)
            }, withStubResponse: {request in
                let (date, challenge, params) = LJServiceTestHelpers.challenge()
                let epochDate = Int32(NSDate().timeIntervalSince1970)
                return OHHTTPStubsResponse(data: params.toResponseData(), statusCode: 200, headers: [:])
        })
    }
    
    class func loginSuccessResponse() -> XMLRPCParam {
        return XMLRPCParam.XStruct([
            "fullname" : XMLRPCParam.XString("person person")
        ])
    }
    
    class func stubLoginResponse(response : OHHTTPStubsResponseBlock) {
        
        let service = LJService()
        let serviceRequest = service.login()
        let credentials = CredentialFactory.freshCredentials()
        let challengeInfo = (credentials : credentials, challenge : "12345")
        let urlRequest = serviceRequest.urlRequest(challengeInfo)
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return self.XMLRPCRequestsMatch(request, urlRequest)
            }, withStubResponse: response)
    }
    
    class func stubLoginSuccess() {
        stubLoginResponse {request in
            let params = LJServiceTestHelpers.loginSuccessResponse()
            return OHHTTPStubsResponse(data: params.toResponseData(), statusCode: 200, headers: [:])
        }
    }
    class func stubLoginFailure() {
        stubLoginResponse { (request) -> OHHTTPStubsResponse! in
            return OHHTTPStubsResponse(error: NSError(domain: "test", code: 1, userInfo: nil))
        }
    }
}
