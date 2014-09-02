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
        
        waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTFail("HTTP Stub unexpectedly timed out")
        })
        
    }

    func testRequestSuccess() {
        // TODO stub response
        
        let result = 100
        var success = false
        
        let data = "<?xml version = \"1.0\" ?><methodResponse><params><param><struct></struct></param></params></methodResponse>"
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL.host == self.testHost
            }, withStubResponse: {request in
                return OHHTTPStubsResponse(data: data.dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: [:])
        })
        
        runTestBody(parser: {param in
            return result
            }, completion: {(n, response, error) in
                success = n == result
        })
            
        XCTAssertTrue(success, "XMLRPCService should handle successful requests")
    }
    
    func failingTest(#message : String) {
        var success = false
        runTestBody(parser: {param in
            XCTFail("Network should have failed. Parser should not be triggered")
            }, completion: {(n, response, error) in
                // todo. check error info
                success = error != nil
        })
        XCTAssertTrue(success, message)
    }
    
    
    func testNetworkFailure() {
        // TODO stub in proper response
        failingTest(message: "NetworkService should handle failures")
    }
    
    func testServerFault() {
        // TODO stub in proper response
        failingTest(message: "NetworkService should handle server faults")
    }
    
    func testParseError() {
        // TODO stub in proper response
        failingTest(message : "NetworkService should handle malformed responses")
    }

}
