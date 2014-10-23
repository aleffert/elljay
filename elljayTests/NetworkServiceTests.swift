
//  NetworkServiceTests.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

class XMLRPCServiceTests : XCTestCase {
    
    override func setUp() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.isEqual(LJService().url)
            }, withStubResponse: {request in

                let challenge = "c0:1073113200:2831:60:2TCbFBYR72f2jhVDuowz:0fba728f5964ea54160a5b18317d92df"
                let epochDate = Int32(NSDate().timeIntervalSince1970)
                let params = XMLRPCParam.XStruct(
                [
                    "challenge" : XMLRPCParam.XString(challenge),
                    "expire_time" : XMLRPCParam.XInt(epochDate),
                    "server_time" : XMLRPCParam.XInt(epochDate)
                ])
                return OHHTTPStubsResponse(data: params.toResponseData(), statusCode: 200, headers: [:])
        })
    }
    
    override func tearDown() {
        OHHTTPStubs.removeLastStub()
    }
    
    let testHost = "test"
    func runTestBody<A>(#parser: NSData -> Result<A>, completion : (Result<A>, NSURLResponse!) -> Void) {
        let service = NetworkService()
        let url = NSURLRequest(URL: NSURL(scheme: "http", host: testHost, path: "/test")!)
        
        let expectation = expectationWithDescription("HTTP stubbed")
        let sessionInfo = AuthSessionInfo(username: "test", password: "test")
        service.sendRequest(urlRequest: url, parser : parser, completionHandler: { (result, response) in
            completion(result, response)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler:nil)
        
    }

    func testRequestSuccess() {
        let result = 100
        var success = false
        
        let response = "<?xml version = \"1.0\" ?><methodResponse><params><param><value><struct></struct></value></param></params></methodResponse>"
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: response.dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: [:])
        })
        
        runTestBody(parser: {param in
            return Success(result)
        }, completion: {(r : Result<Int>, response) -> Void in
                r.ifSuccess {n in
                    success = n == result
                }
                return
        })
        
        OHHTTPStubs.removeLastStub()
            
        XCTAssertTrue(success, "XMLRPCService should handle successful requests")
    }
    
    func failingTest(#message : String, errorDomain : String, errorCode : Int) {
        var success = false
        
        runTestBody(parser: {param in
            return Failure(NSError(domain : errorDomain, code : errorCode, userInfo : [:]))
            }, completion: {(result : Result<Void>, response : NSURLResponse!) in
                result.ifError {e in
                    XCTAssertEqual(errorDomain, e.domain, message)
                    XCTAssertEqual(errorCode, e.code, message)
                    success = true
                }
            return
        })
        XCTAssertTrue(success, message)
    }
    
    
    func testNetworkFailure() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: NSData(), statusCode: 404, headers: [:])
        })

        failingTest(message: "NetworkService should handle failures", errorDomain :  NetworkServiceErrorDomain, errorCode : 404)
        
        OHHTTPStubs.removeLastStub()
    }
    
    func testServerFault() {
        let response = "<?xml version=\"1.0\"?>" +
            "<methodResponse><fault><value><struct>" +
            "<member><name>faultCode</name><value><int>4</int></value></member>" +
            "<member><name>faultString</name><value><string>Too many parameters.</string></value></member>" +
        "</struct></value></fault></methodResponse>"
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: response.dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: [:])
        })
        failingTest(message: "NetworkService should handle server faults", errorDomain: XMLRPCParserErrorDomain, errorCode : 4)
        
        OHHTTPStubs.removeLastStub()
    }
    
    func testParseError() {   
        let response = "<?xml version=\"1.0\"?><asfdasdf>"
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: response.dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: [:])
        })
        
        failingTest(message : "NetworkService should handle malformed responses", errorDomain : LJServiceErrorDomain, errorCode : LJServiceErrorMalformedResponseCode)
        
        OHHTTPStubs.removeLastStub()
    }

}
