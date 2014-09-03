//
//  NetworkServiceTests.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

class XMLRPCServiceTests : XCTestCase {
    
    let testHost = "test"
    func runTestBody<A>(#parser: XMLRPCParam -> A, completion : (A?, NSURLResponse!, NSError?) -> Void) {
        let service = XMLRPCService()
        let url = NSURLRequest(URL: NSURL(scheme: "http", host: testHost, path: "/test"))
        let request : Request<A> = Request(urlRequest: url, parser: parser)
        
        let expectation = expectationWithDescription("HTTP stubbed")
        service.send(request: request, completionHandler: { (n, response, error) in
            // todo. check error info
            completion(n, response, error)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1, handler:nil)
        
    }

    func testRequestSuccess() {
        // TODO stub response
        
        let result = 100
        var success = false
        
        let response = "<?xml version = \"1.0\" ?><methodResponse><params><param><value><struct></struct></value></param></params></methodResponse>"
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: response.dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: [:])
        })
        
        runTestBody(parser: {param in
            return result
            }, completion: {(n, response, error) in
                success = n == result
        })
        
        OHHTTPStubs.removeLastStub()
            
        XCTAssertTrue(success, "XMLRPCService should handle successful requests")
    }
    
    func failingTest(#message : String, errorDomain : String, errorCode : Int) {
        var success = false
        
        runTestBody(parser: {param in
            XCTFail("Network should have failed. Parser should not be triggered")
            }, completion: {(n : Void?, response : NSURLResponse!, error : NSError?) in
                let _ : Void? = error.bind{(e : NSError) in
                    XCTAssertEqual(errorDomain, e.domain, message)
                    XCTAssertEqual(errorCode, e.code, message)
                    success = true
                    return nil
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

        failingTest(message: "NetworkService should handle failures", errorDomain :  XMLRPCServiceErrorDomain, errorCode : XMLRPCServiceErrorMalformedResponseCode)
        
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
        failingTest(message: "NetworkService should handle server faults", errorDomain: XMLRPCResult.errorDomain, errorCode : 4)
        
        OHHTTPStubs.removeLastStub()
    }
    
    func testParseError() {
        
        let response = "<?xml version=\"1.0\"?>" +
            "<asfdasdf>"
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: response.dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: [:])
        })
        
        // TODO stub in proper response
        failingTest(message : "NetworkService should handle malformed responses", errorDomain : XMLRPCServiceErrorDomain, errorCode : XMLRPCServiceErrorMalformedResponseCode)
        
        OHHTTPStubs.removeLastStub()
    }

}
